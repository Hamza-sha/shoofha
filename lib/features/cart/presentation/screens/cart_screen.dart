import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/app/theme/app_theme.dart';
import 'package:shoofha/features/cart/application/cart_controller.dart';

/// شاشة السلة الرئيسية
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final horizontalPadding = width * 0.06;
    final vSpaceSm = height * 0.018;
    final vSpaceMd = height * 0.026;

    final isEmpty = cartState.items.isEmpty;
    final totalItems = cartState.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'السلة',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: isEmpty
              ? _EmptyCart(vSpaceSm: vSpaceSm, vSpaceMd: vSpaceMd)
              : Column(
                  children: [
                    SizedBox(height: vSpaceSm),

                    // ملخص بسيط أعلى
                    _CartHeaderSummary(itemCount: totalItems),
                    SizedBox(height: vSpaceSm),

                    // قائمة المنتجات
                    Expanded(
                      child: ListView.separated(
                        itemCount: cartState.items.length,
                        separatorBuilder: (_, __) => SizedBox(height: vSpaceSm),
                        itemBuilder: (context, index) {
                          final item = cartState.items[index];
                          return _CartItemCard(item: item);
                        },
                      ),
                    ),

                    SizedBox(height: vSpaceSm),

                    // ملخص الفاتورة + زر إتمام الشراء
                    _CartBottomSummary(
                      cartState: cartState,
                      totalItems: totalItems,
                    ),

                    SizedBox(height: vSpaceMd * 0.6),
                  ],
                ),
        ),
      ),
    );
  }
}

/// حالة السلة الفارغة
class _EmptyCart extends StatelessWidget {
  final double vSpaceSm;
  final double vSpaceMd;

  const _EmptyCart({required this.vSpaceSm, required this.vSpaceMd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final vSpaceXs = height * 0.012;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: height * 0.18,
            height: height * 0.18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.navy, AppColors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: height * 0.08,
              ),
            ),
          ),
          SizedBox(height: vSpaceSm),
          Text(
            'سلتك فاضية حالياً',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: vSpaceXs),
          Text(
            'ابدأ باستكشاف المتاجر والمنتجات وأضف ما يعجبك إلى السلة.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          SizedBox(height: vSpaceMd),
          SizedBox(
            width: width * 0.6,
            height: height * 0.055,
            child: FilledButton(
              onPressed: () {
                // رجّعو على الـ MainShell (ممكن لاحقاً نبدّل التاب للاستكشاف)
                context.go('/app');
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.secondary,
              ),
              child: const Text('ابدأ التسوق'),
            ),
          ),
        ],
      ),
    );
  }
}

/// ملخص أعلى: عدد المنتجات
class _CartHeaderSummary extends StatelessWidget {
  final int itemCount;

  const _CartHeaderSummary({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.012,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(height * 0.018),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.light ? 0.04 : 0.22,
            ),
            blurRadius: height * 0.018,
            offset: Offset(0, height * 0.006),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: height * 0.026,
            color: theme.iconTheme.color,
          ),
          SizedBox(width: width * 0.02),
          Expanded(
            child: Text(
              'لديك $itemCount عنصر${itemCount == 1 ? '' : ''} في السلة',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// عنصر واحد في السلة
class _CartItemCard extends ConsumerWidget {
  final CartItem item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final radius = height * 0.020;

    final product = item.product;
    final title = product.name;

    final controller = ref.read(cartControllerProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.light ? 0.03 : 0.20,
            ),
            blurRadius: height * 0.018,
            offset: Offset(0, height * 0.010),
          ),
        ],
      ),
      padding: EdgeInsets.all(width * 0.03),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المنتج / Placeholder ملون حسب لون المنتج
          Container(
            width: height * 0.085,
            height: height * 0.085,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius * 0.8),
              gradient: LinearGradient(
                colors: [
                  product.color.withOpacity(0.95),
                  product.color.withOpacity(0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                product.name.characters.first,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: width * 0.03),

          // معلومات المنتج
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم المنتج + زر حذف
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: width * 0.02),
                    _CartIconButton(
                      icon: Icons.delete_outline_rounded,
                      onPressed: () {
                        controller.removeItem(product.id);
                      },
                    ),
                  ],
                ),
                SizedBox(height: height * 0.006),

                // سعر القطعة
                Text(
                  '${product.price.toStringAsFixed(2)} د.أ للقطعة',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: height * 0.010),

                // الكمية + المجموع
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // التحكم في الكمية
                    Row(
                      children: [
                        _QuantityButton(
                          icon: Icons.remove_rounded,
                          onPressed: () {
                            controller.updateQuantity(
                              product.id,
                              item.quantity - 1,
                            );
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.018,
                          ),
                          child: Text(
                            '${item.quantity}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _QuantityButton(
                          icon: Icons.add_rounded,
                          onPressed: () {
                            controller.updateQuantity(
                              product.id,
                              item.quantity + 1,
                            );
                          },
                        ),
                      ],
                    ),

                    // مجموع هذا المنتج
                    Text(
                      '${item.totalPrice.toStringAsFixed(2)} د.أ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final height = size.height;

    return InkWell(
      borderRadius: BorderRadius.circular(height * 0.016),
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(height * 0.004),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height * 0.016),
          border: Border.all(color: theme.dividerColor.withOpacity(0.6)),
        ),
        child: Icon(icon, size: height * 0.020),
      ),
    );
  }
}

class _CartIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CartIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final height = size.height;

    return InkWell(
      borderRadius: BorderRadius.circular(height * 0.018),
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.all(height * 0.006),
        child: Icon(icon, size: height * 0.020, color: theme.iconTheme.color),
      ),
    );
  }
}

/// ملخص أسفل: المجموع + التوصيل + الإجمالي + زر إتمام الشراء
class _CartBottomSummary extends StatelessWidget {
  final CartState cartState;
  final int totalItems;

  const _CartBottomSummary({required this.cartState, required this.totalItems});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shoofhaTheme = theme.extension<ShoofhaTheme>();
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final vSpaceXs = height * 0.012;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.016,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(height * 0.020),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.light ? 0.05 : 0.24,
            ),
            blurRadius: height * 0.020,
            offset: Offset(0, height * 0.010),
          ),
        ],
      ),
      child: Column(
        children: [
          // ملخص القيم
          _SummaryRow(
            label: 'المجموع (${totalItems} منتج)',
            value: '${cartState.subTotal.toStringAsFixed(2)} د.أ',
          ),
          SizedBox(height: vSpaceXs * 0.7),
          _SummaryRow(
            label: 'رسوم التوصيل',
            value: cartState.deliveryFee == 0
                ? 'مجاني'
                : '${cartState.deliveryFee.toStringAsFixed(2)} د.أ',
            valueStyle: cartState.deliveryFee == 0
                ? theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  )
                : null,
          ),
          SizedBox(height: vSpaceXs),
          Divider(
            height: vSpaceXs * 2,
            color: theme.dividerColor.withOpacity(0.4),
          ),
          SizedBox(height: vSpaceXs * 0.5),
          _SummaryRow(
            label: 'الإجمالي',
            value: '${cartState.total.toStringAsFixed(2)} د.أ',
            isBold: true,
          ),
          SizedBox(height: vSpaceXs * 1.4),

          // زر إتمام الشراء
          SizedBox(
            width: double.infinity,
            height: height * 0.058,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height * 0.016),
                gradient: shoofhaTheme?.primaryButtonGradient,
              ),
              child: FilledButton(
                onPressed: () {
                  // ننتقل لصفحة إتمام الطلب (Checkout)
                  context.goNamed('checkout');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(height * 0.016),
                  ),
                ),
                child: Text(
                  'إتمام الشراء',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final TextStyle? valueStyle;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final baseStyle = theme.textTheme.bodyMedium;
    final labelStyle = isBold
        ? baseStyle?.copyWith(fontWeight: FontWeight.w700)
        : baseStyle;
    final effectiveValueStyle =
        valueStyle ??
        (isBold ? baseStyle?.copyWith(fontWeight: FontWeight.w700) : baseStyle);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        SizedBox(width: width * 0.02),
        Text(
          value,
          style: effectiveValueStyle?.copyWith(
            fontSize: baseStyle?.fontSize ?? height * 0.018,
          ),
        ),
      ],
    );
  }
}
