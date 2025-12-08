import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/core/responsive/responsive.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final _ = Theme.of(context).colorScheme;

    final favOffers = _dummyOffers;
    final favProducts = _dummyProducts;
    final favStores = _dummyStores;

    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.04,
          vertical: h * 0.015,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عروض
            Text(
              'عروض محفوظة',
              style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: h * 0.01),
            favOffers.isEmpty
                ? _EmptySection(text: 'ما حفظت أي عروض لسا 😌')
                : SizedBox(
                    height: h * 0.22,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: favOffers.length,
                      separatorBuilder: (_, __) => SizedBox(width: w * 0.03),
                      itemBuilder: (context, index) {
                        final offer = favOffers[index];
                        return _OfferCard(offer: offer);
                      },
                    ),
                  ),

            SizedBox(height: h * 0.025),

            // منتجات
            Text(
              'منتجات محفوظة',
              style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: h * 0.01),
            favProducts.isEmpty
                ? _EmptySection(
                    text: 'إضف منتجات للسلة أو المفضلة لتظهر هنا 🛒',
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Responsive.isMobile(context) ? 2 : 3,
                      mainAxisSpacing: h * 0.014,
                      crossAxisSpacing: w * 0.03,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final product = favProducts[index];
                      return _ProductCard(product: product);
                    },
                  ),

            SizedBox(height: h * 0.025),

            // متاجر
            Text(
              'متاجر تتابعها',
              style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: h * 0.01),
            favStores.isEmpty
                ? _EmptySection(text: 'تابع متاجر ليظهروا هون 🏪')
                : Column(
                    children: favStores.map((store) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: h * 0.012),
                        child: _StoreTile(store: store),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String text;

  const _EmptySection({required this.text});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: w * 0.02),
      child: Text(
        text,
        style: TextStyle(
          fontSize: w * 0.035,
          color: cs.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }
}

// عروض

class _FavoriteOffer {
  final String id;
  final String title;
  final String storeName;
  final String badge;
  final Color color;
  final String storeId;

  _FavoriteOffer({
    required this.id,
    required this.title,
    required this.storeName,
    required this.badge,
    required this.color,
    required this.storeId,
  });
}

class _OfferCard extends StatelessWidget {
  final _FavoriteOffer offer;

  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);

    return GestureDetector(
      onTap: () {
        context.pushNamed('store', pathParameters: {'id': offer.storeId});
      },
      child: Container(
        width: w * 0.6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              offer.color.withOpacity(0.9),
              offer.color.withOpacity(0.65),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(w * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.02,
                      vertical: w * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      offer.badge,
                      style: TextStyle(
                        fontSize: w * 0.032,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    offer.storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: w * 0.04,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: h * 0.004),
                  Text(
                    offer.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: w * 0.033,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// منتجات

class _FavoriteProduct {
  final String id;
  final String name;
  final double price;
  final Color color;
  final String productId;

  _FavoriteProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.color,
    required this.productId,
  });
}

class _ProductCard extends StatelessWidget {
  final _FavoriteProduct product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.pushNamed('product', pathParameters: {'id': product.productId});
      },
      child: Ink(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: h * 0.12,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
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
                    fontSize: w * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.02,
                vertical: h * 0.006,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: w * 0.038,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: h * 0.004),
                  Text(
                    '${product.price.toStringAsFixed(2)} د.أ',
                    style: TextStyle(
                      fontSize: w * 0.034,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// متاجر

class _FavoriteStore {
  final String id;
  final String name;
  final String category;
  final double distanceKm;

  _FavoriteStore({
    required this.id,
    required this.name,
    required this.category,
    required this.distanceKm,
  });
}

class _StoreTile extends StatelessWidget {
  final _FavoriteStore store;

  const _StoreTile({required this.store});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.pushNamed('store', pathParameters: {'id': store.id});
      },
      child: Ink(
        padding: EdgeInsets.all(w * 0.03),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cs.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: w * 0.055,
              child: Text(
                store.name.characters.first,
                style: TextStyle(
                  fontSize: w * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: w * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: TextStyle(
                      fontSize: w * 0.038,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: w * 0.005),
                  Row(
                    children: [
                      Text(
                        store.category,
                        style: TextStyle(
                          fontSize: w * 0.032,
                          color: cs.onSurface.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(width: w * 0.02),
                      Icon(
                        Icons.location_on_outlined,
                        size: w * 0.04,
                        color: cs.onSurface.withOpacity(0.7),
                      ),
                      Text(
                        '${store.distanceKm.toStringAsFixed(1)} كم',
                        style: TextStyle(
                          fontSize: w * 0.032,
                          color: cs.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy data

final List<_FavoriteOffer> _dummyOffers = [
  _FavoriteOffer(
    id: 'off1',
    title: 'خصم 30% على جميع المشروبات الباردة اليوم فقط 🧊',
    storeName: 'Coffee Mood',
    badge: 'عرض مميز',
    color: const Color(0xFF6A1B9A),
    storeId: 'coffee-mood',
  ),
  _FavoriteOffer(
    id: 'off2',
    title: 'اشتراك 3 أشهر بسعر شهرين 💪',
    storeName: 'FitZone Gym',
    badge: 'اشتراك',
    color: const Color(0xFF1B5E20),
    storeId: 'fit-zone',
  ),
];

final List<_FavoriteProduct> _dummyProducts = [
  _FavoriteProduct(
    id: 'favp1',
    name: 'سماعات لاسلكية Pro',
    price: 49.0,
    color: const Color(0xFF0D47A1),
    productId: 'earbuds-pro',
  ),
  _FavoriteProduct(
    id: 'favp2',
    name: 'باور بانك 20,000mAh',
    price: 29.0,
    color: const Color(0xFF1976D2),
    productId: 'power-bank',
  ),
];

final List<_FavoriteStore> _dummyStores = [
  _FavoriteStore(
    id: 'coffee-mood',
    name: 'Coffee Mood',
    category: 'كافيه',
    distanceKm: 1.3,
  ),
  _FavoriteStore(
    id: 'tech-corner',
    name: 'Tech Corner',
    category: 'الكترونيات',
    distanceKm: 4.8,
  ),
];
