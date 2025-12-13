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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                            color: Colors.black.withOpacity(0.04),
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
                              style: Theme.of(context).textTheme.bodyMedium,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: h * 0.008),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cartItems.length,
                      separatorBuilder: (_, __) => SizedBox(height: h * 0.01),
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final product = item.product;

                        StoreModel? store;
                        try {
                          store = kStores.firstWhere(
                            (s) => s.id == product.storeId,
                          );
                        } catch (_) {
                          store = null;
                        }

                        return _CheckoutItemTile(
                          product: product,
                          quantity: item.quantity,
                          storeName: store?.name ?? 'متجر',
                        );
                      },
                    ),

                    SizedBox(height: h * 0.025),

                    Text(
                      'طريقة الدفع',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                        border: Border.all(color: cs.primary.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.money_rounded,
                            color: cs.primary,
                            size: w * 0.07,
                          ),
                          SizedBox(width: w * 0.03),
                          Expanded(
                            child: Text(
                              'الدفع عند الاستلام',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const Icon(Icons.check_circle, color: Colors.green),
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
                      color: Colors.black.withOpacity(0.06),
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

    return Container(
      padding: EdgeInsets.all(w * 0.03),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withOpacity(0.3)),
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
                  product.color.withOpacity(0.9),
                  product.color.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                product.name.characters.first,
                style: TextStyle(
                  fontSize: w * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: h * 0.003),
                Text(
                  storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.primary.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: h * 0.003),
                Text(
                  '${product.price.toStringAsFixed(2)} د.أ للقطعة',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(width: w * 0.02),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('x$quantity', style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: h * 0.003),
              Text(
                '${(product.price * quantity).toStringAsFixed(2)} د.أ',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
    final textTheme = Theme.of(context).textTheme;

    final textStyle = isBold
        ? textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
        : textTheme.bodyMedium;

    final valueStyle = isBold
        ? textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
        : textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Text('${value.toStringAsFixed(2)} د.أ', style: valueStyle),
      ],
    );
  }
}
