import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/core/responsive/responsive.dart';
import 'package:shoofha/features/cart/application/cart_controller.dart';
import 'package:shoofha/features/store/domain/store_models.dart';
import 'package:shoofha/features/commerce/presentation/screens/order_success_screen.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  String _generateOrderId() {
    final ms = DateTime.now().millisecondsSinceEpoch;
    return 'SH-$ms';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartControllerProvider);
    final cartItems = cartState.items;

    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إتمام الطلب'), centerTitle: true),
        body: cartItems.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.1),
                  child: Text(
                    'لا يوجد عناصر في السلة لإتمام الطلب.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
                    Text(
                      'عنوان التوصيل',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: h * 0.008),
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
                            onPressed: () {},
                            child: const Text('تعديل'),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.025),

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
                        ),
                      );
                    }),

                    SizedBox(height: h * 0.02),

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
                      child: Row(
                        children: [
                          Icon(Icons.payments_outlined, color: cs.primary),
                          SizedBox(width: w * 0.03),
                          Expanded(
                            child: Text(
                              'الدفع عند الاستلام',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.withValues(alpha: 0.95),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.14),
                  ],
                ),
              ),
        bottomNavigationBar: cartItems.isEmpty
            ? null
            : Container(
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
                    _SummaryRow(label: 'التوصيل', value: cartState.deliveryFee),
                    Divider(height: h * 0.03),
                    _SummaryRow(
                      label: 'الإجمالي',
                      value: cartState.total,
                      isBold: true,
                    ),
                    SizedBox(height: h * 0.015),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final orderId = _generateOrderId();
                          final total = cartState.total;

                          // ✅ امسح السلة
                          ref.read(cartControllerProvider.notifier).clear();

                          // ✅ روح على نجاح الطلب
                          context.goNamed(
                            'order-success',
                            extra: OrderSuccessArgs(
                              orderId: orderId,
                              total: total,
                            ),
                          );
                        },
                        child: const Text('تأكيد الطلب'),
                      ),
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

  const _CheckoutItemTile({
    required this.product,
    required this.quantity,
    required this.storeName,
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
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
