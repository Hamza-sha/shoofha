import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/core/responsive/responsive.dart';
import 'package:shoofha/features/cart/application/cart_controller.dart';
import 'package:shoofha/features/main_shell/presentation/main_shell.dart';
import 'package:shoofha/features/store/domain/store_models.dart';
import 'package:shoofha/features/commerce/presentation/screens/order_success_screen.dart';

enum DeliveryMethod { delivery, pickup }

enum PaymentMethod { cashOnDelivery, visa }

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _submitting = false;

  DeliveryMethod _deliveryMethod = DeliveryMethod.delivery;
  PaymentMethod _paymentMethod = PaymentMethod.cashOnDelivery;

  // ✅ Undo Queue (ذكي + آمن)
  final List<_UndoRemoval> _undoQueue = <_UndoRemoval>[];
  bool _snackShowing = false;

  String _generateOrderId() {
    final ms = DateTime.now().millisecondsSinceEpoch;
    return 'SH-$ms';
  }

  void _safeBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }

    // ✅ fallback آمن
    MainShellTabs.goCart();
    context.go('/app');
  }

  void _placeOrder(BuildContext context) {
    if (_submitting) return;

    final cartState = ref.read(cartControllerProvider);
    if (cartState.items.isEmpty) return;

    setState(() => _submitting = true);

    final orderId = _generateOrderId();
    final total = cartState.total;

    ref.read(cartControllerProvider.notifier).clear();

    context.goNamed(
      'order-success',
      extra: OrderSuccessArgs(orderId: orderId, total: total),
    );
  }

  void _enqueueUndo({
    required ScaffoldMessengerState messenger,
    required _UndoRemoval removal,
  }) {
    _undoQueue.add(removal);
    _showNextUndoIfNeeded(messenger);
  }

  void _showNextUndoIfNeeded(ScaffoldMessengerState messenger) {
    if (_snackShowing) return;
    if (_undoQueue.isEmpty) return;
    if (!mounted) return; // ✅ حماية إضافية

    _snackShowing = true;

    final current = _undoQueue.first;

    // ما نمسح القديم: نعمل hide للحالي عشان يصير Queue مرتب
    messenger.hideCurrentSnackBar();

    messenger
        .showSnackBar(
          SnackBar(
            content: Text('تم حذف ${current.productName}'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'تراجع',
              onPressed: () {
                current.undo();
                current.didUndo = true; // ✅ الآن always initialized
              },
            ),
          ),
        )
        .closed
        .then((_) {
          // ✅ لو انسكر السناك: نشيل العنصر ونعرض اللي بعده
          if (_undoQueue.isNotEmpty && identical(_undoQueue.first, current)) {
            _undoQueue.removeAt(0);
          } else {
            // احتياط لو صار اختلاف
            _undoQueue.remove(current);
          }

          _snackShowing = false;

          if (!mounted) return;

          // ✅ (اختياري) لو بدك Feedback صغير بعد التراجع
          // if (current.didUndo) {
          //   messenger.showSnackBar(
          //     const SnackBar(
          //       content: Text('تم التراجع عن الحذف'),
          //       duration: Duration(milliseconds: 900),
          //       behavior: SnackBarBehavior.floating,
          //     ),
          //   );
          // }

          _showNextUndoIfNeeded(messenger);
        });
  }

  void _removeItemWithUndo(BuildContext context, CartItem item) {
    final cartNotifier = ref.read(cartControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);

    // احذف
    cartNotifier.removeItem(item.product.id);

    // جهّز undo entry (بدون ref داخل SnackBar)
    final removal = _UndoRemoval(
      productName: item.product.name,
      undo: () {
        cartNotifier.addItem(item.product, quantity: item.quantity);
      },
      // didUndo: false // ✅ مش ضروري لأنه صار default
    );

    _enqueueUndo(messenger: messenger, removal: removal);
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final cartItems = cartState.items;

    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إتمام الطلب'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => _safeBack(context),
          ),
        ),

        /// ===== Body =====
        body: cartItems.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'لا يوجد عناصر في السلة لإتمام الطلب.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: h * 0.02),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _safeBack(context),
                          child: const Text('الرجوع للسلة'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.06,
                  vertical: h * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ===== Delivery Method =====
                    Text(
                      'طريقة الاستلام',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: h * 0.010),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(w * 0.035),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: cs.outline.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        children: [
                          _ChoiceRow(
                            icon: Icons.local_shipping_outlined,
                            title: 'توصيل للعنوان',
                            selected:
                                _deliveryMethod == DeliveryMethod.delivery,
                            onTap: () {
                              setState(() {
                                _deliveryMethod = DeliveryMethod.delivery;
                              });
                            },
                          ),
                          SizedBox(height: h * 0.008),
                          _ChoiceRow(
                            icon: Icons.store_mall_directory_outlined,
                            title: 'الاستلام من المتجر',
                            selected: _deliveryMethod == DeliveryMethod.pickup,
                            onTap: () {
                              setState(() {
                                _deliveryMethod = DeliveryMethod.pickup;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.025),

                    /// ===== Address =====
                    Text(
                      _deliveryMethod == DeliveryMethod.delivery
                          ? 'عنوان التوصيل'
                          : 'موقع الاستلام',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: h * 0.008),

                    if (_deliveryMethod == DeliveryMethod.delivery)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(w * 0.035),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: cs.primary,
                              size: w * 0.07,
                            ),
                            SizedBox(width: w * 0.03),
                            Expanded(
                              child: Text(
                                'عمّان، الأردن\nيمكنك لاحقاً ربطه بعنوان المستخدم من البروفايل.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO
                              },
                              child: const Text('تعديل'),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(w * 0.035),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.storefront_outlined,
                              color: cs.primary,
                              size: w * 0.07,
                            ),
                            SizedBox(width: w * 0.03),
                            Expanded(
                              child: Text(
                                'سيتم تجهيز الطلب للاستلام من المتجر.\n(سيظهر عنوان المتجر الحقيقي لاحقاً)',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: h * 0.025),

                    /// ===== Products =====
                    Text(
                      'المنتجات',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: h * 0.010),

                    ...cartItems.map((item) {
                      final store = kStores.firstWhere(
                        (s) => s.id == item.product.storeId,
                        orElse: () => StoreModel(
                          id: 'unknown',
                          name: 'متجر',
                          category: '',
                          rating: 0,
                          distanceKm: 0,
                          color: cs.primary,
                        ),
                      );

                      return Padding(
                        padding: EdgeInsets.only(bottom: h * 0.010),
                        child: _CheckoutItemTile(
                          product: item.product,
                          quantity: item.quantity,
                          storeName: store.name,
                          onRemove: () => _removeItemWithUndo(context, item),
                        ),
                      );
                    }),

                    SizedBox(height: h * 0.02),

                    /// ===== Payment =====
                    Text(
                      'طريقة الدفع',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: h * 0.010),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(w * 0.035),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: cs.outline.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        children: [
                          _ChoiceRow(
                            icon: Icons.payments_outlined,
                            title: 'الدفع عند الاستلام',
                            selected:
                                _paymentMethod == PaymentMethod.cashOnDelivery,
                            trailing: Icon(
                              Icons.check_circle,
                              color: Colors.green.withValues(alpha: 0.95),
                            ),
                            onTap: () {
                              setState(() {
                                _paymentMethod = PaymentMethod.cashOnDelivery;
                              });
                            },
                          ),
                          SizedBox(height: h * 0.010),
                          _ChoiceRow(
                            icon: Icons.credit_card,
                            title: 'Visa / MasterCard',
                            subtitle: 'قريباً',
                            enabled: false,
                            selected: _paymentMethod == PaymentMethod.visa,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.03),
                  ],
                ),
              ),

        /// ===== Bottom CTA =====
        bottomNavigationBar: cartItems.isEmpty
            ? null
            : SafeArea(
                top: false,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.06,
                    vertical: h * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SummaryRow(label: 'المجموع', value: cartState.subTotal),
                      SizedBox(height: h * 0.006),
                      _SummaryRow(
                        label: 'التوصيل',
                        value: _deliveryMethod == DeliveryMethod.pickup
                            ? 0
                            : cartState.deliveryFee,
                      ),
                      Divider(height: h * 0.03),
                      _SummaryRow(
                        label: 'الإجمالي',
                        value: _deliveryMethod == DeliveryMethod.pickup
                            ? cartState.subTotal
                            : cartState.total,
                        isBold: true,
                      ),
                      SizedBox(height: h * 0.015),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _submitting
                              ? null
                              : () => _placeOrder(context),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: _submitting
                                ? Row(
                                    key: const ValueKey('loading'),
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: h * 0.022,
                                        height: h * 0.022,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                        ),
                                      ),
                                      SizedBox(width: w * 0.02),
                                      const Text('جاري تأكيد الطلب...'),
                                    ],
                                  )
                                : const Text(
                                    'تأكيد الطلب',
                                    key: ValueKey('cta'),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _UndoRemoval {
  final String productName;
  final VoidCallback undo;

  // ✅ FIX: لازم قيمة افتراضية لأنه non-nullable
  bool didUndo;

  _UndoRemoval({
    required this.productName,
    required this.undo,
    this.didUndo = false, // ✅ أهم تعديل لحل الخطأ
  });
}

/// ✅ نفس ستايلك، بس Widget صغير يساعدنا نعمل اختيار (Radio-like)
class _ChoiceRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final bool enabled;
  final Widget? trailing;
  final VoidCallback onTap;

  const _ChoiceRow({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.enabled = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: w * 0.01),
          child: Row(
            children: [
              Icon(icon, color: cs.primary),
              SizedBox(width: w * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.bodyMedium),
                    if (subtitle != null)
                      Padding(
                        padding: EdgeInsets.only(top: w * 0.01),
                        child: Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[trailing!, SizedBox(width: w * 0.02)],
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? cs.primary : cs.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutItemTile extends StatelessWidget {
  final StoreProduct product;
  final int quantity;
  final String storeName;
  final VoidCallback onRemove;

  const _CheckoutItemTile({
    required this.product,
    required this.quantity,
    required this.storeName,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(w * 0.03),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Container(
            width: w * 0.12,
            height: w * 0.12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  product.color.withValues(alpha: 0.90),
                  product.color.withValues(alpha: 0.60),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                product.name.isNotEmpty ? product.name.characters.first : '?',
                style: TextStyle(
                  fontSize: w * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.98),
                ),
              ),
            ),
          ),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: EdgeInsets.all(w * 0.015),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: w * 0.055,
                          color: cs.error.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h * 0.003),
                Text(
                  storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.primary.withValues(alpha: 0.75),
                  ),
                ),
                SizedBox(height: h * 0.003),
                Text(
                  '${product.price.toStringAsFixed(2)} د.أ للقطعة',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(width: w * 0.02),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('x$quantity', style: theme.textTheme.bodyMedium),
              SizedBox(height: h * 0.003),
              Text(
                '${(product.price * quantity).toStringAsFixed(2)} د.أ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style =
        (isBold
                ? theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  )
                : theme.textTheme.bodyMedium)
            ?.copyWith(height: 1.2);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('${value.toStringAsFixed(2)} د.أ', style: style),
      ],
    );
  }
}
