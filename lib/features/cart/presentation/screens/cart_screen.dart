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
                    _CartHeaderSummary(itemCount: totalItems),
                    SizedBox(height: vSpaceSm),
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

/// ✅ SnackBar سريع ومرتب + Undo آمن (بدون ref داخل الـ callback)
void _showQuickUndoSnackBar({
  required BuildContext context,
  required String message,
  required String actionLabel,
  required VoidCallback onUndo,
}) {
  final theme = Theme.of(context);
  final size = MediaQuery.sizeOf(context);
  final height = size.height;

  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();

  messenger.showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onInverseSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      duration: const Duration(milliseconds: 1200),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(
        horizontal: height * 0.02,
        vertical: height * 0.02,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(height * 0.018),
      ),
      backgroundColor: theme.colorScheme.inverseSurface,
      action: SnackBarAction(
        label: actionLabel,
        textColor: theme.colorScheme.secondary,
        onPressed: onUndo,
      ),
    ),
  );
}

/// حالة السلة الفارغة
class _EmptyCart extends StatelessWidget {
  final double vSpaceSm;
  final double vSpaceMd;

  const _EmptyCart({required this.vSpaceSm, required this.vSpaceMd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shoofhaTheme = theme.extension<ShoofhaTheme>();
    final colorScheme = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final vSpaceXs = height * 0.012;
    final radius = height * 0.02;

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
            width: width * 0.7,
            height: height * 0.058,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient:
                    shoofhaTheme?.primaryButtonGradient ??
                    const LinearGradient(
                      colors: [AppColors.navy, AppColors.purple],
                    ),
              ),
              child: FilledButton(
                onPressed: () => context.go('/app'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius),
                  ),
                ),
                child: Text(
                  'ابدأ التسوق',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: height * 0.012),

          TextButton(
            onPressed: () => context.go('/app'),
            child: Text(
              'استكشاف الريلز',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ملخص أعلى
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
          Icon(Icons.shopping_bag_outlined, size: height * 0.026),
          SizedBox(width: width * 0.02),
          Expanded(
            child: Text(
              'لديك $itemCount عنصر في السلة',
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

    // ✅ خذ notifier مرة واحدة (آمن) بدل ref داخل Undo
    final cartNotifier = ref.read(cartControllerProvider.notifier);

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _CartIconButton(
                      icon: Icons.delete_outline_rounded,
                      onPressed: () {
                        // ✅ Snapshot آمن
                        final removedProduct = item.product;
                        final removedQty = item.quantity;

                        cartNotifier.removeItem(removedProduct.id);

                        _showQuickUndoSnackBar(
                          context: context,
                          message: 'تم حذف ${removedProduct.name}',
                          actionLabel: 'تراجع',
                          onUndo: () {
                            // ✅ بدون ref نهائياً -> ما في unmounted error
                            cartNotifier.addItem(
                              removedProduct,
                              quantity: removedQty,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: height * 0.006),
                Text(
                  '${product.price.toStringAsFixed(2)} د.أ للقطعة',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: height * 0.010),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _QuantityButton(
                          icon: Icons.remove_rounded,
                          onPressed: item.quantity > 1
                              ? () {
                                  cartNotifier.updateQuantity(
                                    product.id,
                                    item.quantity - 1,
                                  );
                                }
                              : null,
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
                            cartNotifier.updateQuantity(
                              product.id,
                              item.quantity + 1,
                            );
                          },
                        ),
                      ],
                    ),
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
  final VoidCallback? onPressed;

  const _QuantityButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final height = size.height;

    return InkWell(
      borderRadius: BorderRadius.circular(height * 0.016),
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(height * 0.004),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height * 0.016),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.6),
          ),
        ),
        child: Icon(
          icon,
          size: height * 0.020,
          color: onPressed == null ? Colors.grey : null,
        ),
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
    final size = MediaQuery.sizeOf(context);
    final height = size.height;

    return InkWell(
      borderRadius: BorderRadius.circular(height * 0.018),
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.all(height * 0.006),
        child: Icon(icon, size: height * 0.020),
      ),
    );
  }
}

/// ملخص أسفل
class _CartBottomSummary extends StatelessWidget {
  final CartState cartState;
  final int totalItems;

  const _CartBottomSummary({required this.cartState, required this.totalItems});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shoofhaTheme = theme.extension<ShoofhaTheme>();
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final isDisabled = cartState.items.isEmpty;

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
          _SummaryRow(
            label: 'الإجمالي',
            value: '${cartState.total.toStringAsFixed(2)} د.أ',
            isBold: true,
          ),
          SizedBox(height: height * 0.02),
          SizedBox(
            width: double.infinity,
            height: height * 0.058,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height * 0.016),
                gradient: isDisabled
                    ? null
                    : shoofhaTheme?.primaryButtonGradient,
                color: isDisabled ? Colors.grey.shade400 : null,
              ),
              child: FilledButton(
                onPressed: isDisabled
                    ? null
                    : () => context.goNamed('checkout'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  'إتمام الشراء',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
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

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? baseStyle?.copyWith(fontWeight: FontWeight.w700)
              : baseStyle,
        ),
        Text(
          value,
          style: isBold
              ? baseStyle?.copyWith(fontWeight: FontWeight.w700)
              : baseStyle,
        ),
      ],
    );
  }
}
