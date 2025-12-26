import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/core/responsive/responsive.dart';
import 'package:shoofha/core/theme/app_colors.dart';
import 'package:shoofha/features/main_shell/presentation/main_shell.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _safeBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    MainShellTabs.goProfile();
    context.go('/app');
  }

  void _goExplore(BuildContext context) {
    MainShellTabs.goExplore();
    context.go('/app');
  }

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final favOffers = _dummyOffers;
    final favProducts = _dummyProducts;
    final favStores = _dummyStores;

    bool matches(String text) {
      final q = _query.trim().toLowerCase();
      if (q.isEmpty) return true;
      return text.toLowerCase().contains(q);
    }

    final filteredOffers = favOffers.where((o) {
      return matches(o.title) || matches(o.storeName) || matches(o.badge);
    }).toList();

    final filteredProducts = favProducts.where((p) {
      return matches(p.name) || matches(p.price.toString());
    }).toList();

    final filteredStores = favStores.where((s) {
      return matches(s.name) || matches(s.category);
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _FavoritesHeader(
                title: 'المفضلة',
                subtitle: 'كل الأشياء اللي حبيتها… بمكان واحد ❤️',
                onBack: () => _safeBack(context),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.06,
                  vertical: h * 0.014,
                ),
                child: _SearchBar(
                  hintText: 'ابحث في المفضلة...',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(h * 0.020),
                    border: Border.all(color: cs.outline.withOpacity(0.18)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: cs.secondary.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(h * 0.018),
                    ),
                    labelStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    unselectedLabelStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'العروض'),
                      Tab(text: 'المنتجات'),
                      Tab(text: 'المتاجر'),
                    ],
                  ),
                ),
              ),

              SizedBox(height: h * 0.012),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // ===== Offers (✅ Grid مربعات) =====
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.06,
                        vertical: h * 0.010,
                      ),
                      child: filteredOffers.isEmpty
                          ? _EmptyState(
                              title: _query.trim().isEmpty
                                  ? 'ما حفظت أي عروض لسا 😌'
                                  : 'ما لقينا عروض',
                              subtitle: _query.trim().isEmpty
                                  ? 'لما تحفظ عرض رح تلاقيه هون فوراً.'
                                  : 'جرّب كلمة ثانية أو امسح البحث.',
                              ctaText: 'استكشف العروض',
                              onCta: () => _goExplore(context),
                            )
                          : _OffersGrid(offers: filteredOffers),
                    ),

                    // ===== Products =====
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.06,
                        vertical: h * 0.010,
                      ),
                      child: filteredProducts.isEmpty
                          ? _EmptyState(
                              title: _query.trim().isEmpty
                                  ? 'ما عندك منتجات محفوظة'
                                  : 'ما لقينا منتجات',
                              subtitle: _query.trim().isEmpty
                                  ? 'احفظ منتجاتك المفضلة عشان ترجع إلها بسرعة.'
                                  : 'جرّب كلمة ثانية أو امسح البحث.',
                              ctaText: 'استكشف المنتجات',
                              onCta: () => _goExplore(context),
                            )
                          : _ProductsGrid(products: filteredProducts),
                    ),

                    // ===== Stores =====
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.06,
                        vertical: h * 0.010,
                      ),
                      child: filteredStores.isEmpty
                          ? _EmptyState(
                              title: _query.trim().isEmpty
                                  ? 'ما بتتابع متاجر حالياً'
                                  : 'ما لقينا متاجر',
                              subtitle: _query.trim().isEmpty
                                  ? 'تابع متاجر لتحصل على عروضهم أول بأول.'
                                  : 'جرّب كلمة ثانية أو امسح البحث.',
                              ctaText: 'استكشف المتاجر',
                              onCta: () => _goExplore(context),
                            )
                          : ListView.separated(
                              itemCount: filteredStores.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: h * 0.012),
                              itemBuilder: (context, index) {
                                final store = filteredStores[index];
                                return _StoreTile(store: store);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _FavoritesHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final headerHeight = h * 0.18;

    return Container(
      height: headerHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.purple],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.06, vertical: h * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BackButton(onPressed: onBack),
                Icon(
                  Icons.favorite_rounded,
                  color: Colors.white.withOpacity(0.92),
                  size: h * 0.032,
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: h * 0.030,
              ),
            ),
            SizedBox(height: h * 0.006),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.86),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.15),
        borderRadius: BorderRadius.circular(h * 0.014),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.hintText, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.006),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(h * 0.02),
        border: Border.all(color: cs.outline.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.light ? 0.03 : 0.18,
            ),
            blurRadius: h * 0.014,
            offset: Offset(0, h * 0.006),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: theme.hintColor),
          SizedBox(width: w * 0.02),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          SizedBox(width: w * 0.01),
          Icon(Icons.tune_rounded, color: theme.hintColor),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String ctaText;
  final VoidCallback onCta;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    final h = Responsive.height(context);
    final w = Responsive.width(context);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: h * 0.18,
              height: h * 0.18,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.teal, AppColors.purple],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                color: Colors.white,
                size: h * 0.08,
              ),
            ),
            SizedBox(height: h * 0.02),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: h * 0.008),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: h * 0.022),
            SizedBox(
              width: w * 0.62,
              height: h * 0.055,
              child: FilledButton(onPressed: onCta, child: Text(ctaText)),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= Offers (✅ Grid مربعات) =======================

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

class _OffersGrid extends StatelessWidget {
  final List<_FavoriteOffer> offers;

  const _OffersGrid({required this.offers});

  int _columnsForWidth(double w) {
    if (w >= 1200) return 4;
    if (w >= 900) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);

    final cols = _columnsForWidth(w);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: offers.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: h * 0.014,
        crossAxisSpacing: w * 0.03,
        childAspectRatio: 1, // ✅ مربعات
      ),
      itemBuilder: (context, index) {
        final offer = offers[index];
        return _OfferSquareCard(offer: offer);
      },
    );
  }
}

class _OfferSquareCard extends StatelessWidget {
  final _FavoriteOffer offer;

  const _OfferSquareCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.pushNamed('store', pathParameters: {'id': offer.storeId});
      },
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              offer.color.withOpacity(0.90),
              offer.color.withOpacity(0.55),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                theme.brightness == Brightness.light ? 0.06 : 0.22,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.62),
                        Colors.black.withOpacity(0.08),
                      ],
                    ),
                  ),
                ),
              ),

              // play icon
              Center(
                child: Container(
                  padding: EdgeInsets.all(w * 0.020),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.22)),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: w * 0.085,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
              ),

              // badge
              Positioned(
                top: w * 0.025,
                left: w * 0.025,
                child: _MiniBadge(text: offer.badge),
              ),

              // bottom text
              Positioned(
                right: w * 0.03,
                left: w * 0.03,
                bottom: w * 0.03,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.storeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: w * 0.010),
                    Text(
                      offer.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.90),
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String text;

  const _MiniBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.022, vertical: w * 0.010),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.40),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.95),
          fontWeight: FontWeight.w800,
          fontSize: w * 0.030,
        ),
      ),
    );
  }
}

// ======================= Products =======================

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

class _ProductsGrid extends StatelessWidget {
  final List<_FavoriteProduct> products;

  const _ProductsGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);

    int crossAxisCount;
    if (w >= 1200) {
      crossAxisCount = 4;
    } else if (w >= 900) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: h * 0.014,
        crossAxisSpacing: w * 0.03,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductCard(product: product);
      },
    );
  }
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
                  product.name.isNotEmpty ? product.name.characters.first : '?',
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: h * 0.004),
                  Text(
                    '${product.price.toStringAsFixed(2)} د.أ',
                    style: TextStyle(
                      fontSize: w * 0.034,
                      fontWeight: FontWeight.w800,
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

// ======================= Stores =======================

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
                store.name.isNotEmpty ? store.name.characters.first : '?',
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
                      fontWeight: FontWeight.w700,
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

// ======================= Dummy data =======================

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
