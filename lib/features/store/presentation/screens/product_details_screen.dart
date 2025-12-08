import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoofha/core/responsive/responsive.dart';
import 'package:shoofha/core/auth/guest_guard.dart';
import 'package:shoofha/features/store/domain/store_models.dart';
import 'package:shoofha/features/cart/application/cart_controller.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  late StoreProduct product;

  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    final p = getProductById(widget.productId);
    product =
        p ??
        StoreProduct(
          id: 'not-found',
          storeId: 'unknown',
          name: 'منتج غير متوفر',
          description: 'هذا المنتج غير متوفر حالياً.',
          price: 0,
          color: Colors.grey,
        );
  }

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: w * 0.6,
                height: w * 0.6,
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
                      fontSize: w * 0.12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: h * 0.02),

            Text(
              product.name,
              style: TextStyle(fontSize: w * 0.05, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: h * 0.008),
            Text(
              '${product.price.toStringAsFixed(2)} د.أ',
              style: TextStyle(
                fontSize: w * 0.045,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
            SizedBox(height: h * 0.02),

            Text(
              'تفاصيل المنتج',
              style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: h * 0.006),
            Text(
              product.description,
              style: TextStyle(fontSize: w * 0.035, height: 1.4),
            ),
            SizedBox(height: h * 0.02),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الكمية',
                  style: TextStyle(
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_quantity > 1) {
                          setState(() {
                            _quantity--;
                          });
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      '$_quantity',
                      style: TextStyle(
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: h * 0.02),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final ok = await requireLogin(context);
                  if (!ok) return;

                  // أضف المنتج للسلة عبر CartController باستخدام Riverpod
                  ref
                      .read(cartControllerProvider.notifier)
                      .addItem(product, quantity: _quantity);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم إضافة $_quantity × ${product.name} إلى السلة',
                      ),
                    ),
                  );
                },
                child: const Text('أضف إلى السلة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
