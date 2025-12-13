import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/core/theme/app_colors.dart';
import 'package:shoofha/features/store/domain/store_models.dart';
import 'package:shoofha/core/auth/guest_guard.dart';

class StoreProfileScreen extends StatefulWidget {
  final String storeId;

  const StoreProfileScreen({super.key, required this.storeId});

  @override
  State<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  late StoreModel store;
  late List<StoreProduct> storeProducts;

  int _currentTabIndex = 0; // 0: Reels, 1: Products, 2: Reviews
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();

    // نحاول نجيب المتجر حسب الـ id، لو ما لقيناه ناخذ أول واحد تجريبي
    store = kStores.firstWhere(
      (s) => s.id == widget.storeId,
      orElse: () => kStores.first,
    );

    // المنتجات الخاصة بالمتجر
    storeProducts = kStoreProducts.where((p) => p.storeId == store.id).toList();
  }

  Future<void> _toggleFavorite() async {
    final allowed = await requireLogin(context);
    if (!allowed) return;

    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _openProduct(StoreProduct product) {
    context.pushNamed('product', pathParameters: {'id': product.id});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final horizontalPadding = width * 0.06;
    final vSpaceMd = height * 0.024;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _StoreHeader(
                store: store,
                isFavorite: _isFavorite,
                onBack: () => Navigator.of(context).maybePop(),
                onToggleFavorite: _toggleFavorite,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: vSpaceMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StoreStatsRow(store: store),
                      SizedBox(height: height * 0.022),

                      const _SectionTitle(title: 'عن المتجر'),
                      SizedBox(height: height * 0.008),
                      Text(
                        'متجر ${store.category} يقدم عروض وخدمات مميزة لعملائه في المنطقة المحيطة. يمكنك هنا إضافة وصف حقيقي من لوحة التاجر لاحقاً.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.85,
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.024),

                      const _SectionTitle(title: 'مميزات المتجر'),
                      SizedBox(height: height * 0.012),
                      const _StoreTagsRow(),

                      SizedBox(height: height * 0.024),

                      // Tabs: ريلز / منتجات / تقييمات
                      _StoreTabs(
                        currentIndex: _currentTabIndex,
                        onChanged: (i) {
                          setState(() => _currentTabIndex = i);
                        },
                      ),
                      SizedBox(height: height * 0.016),

                      // محتوى التبويب
                      if (_currentTabIndex == 0)
                        _StoreReelsPlaceholder(store: store)
                      else if (_currentTabIndex == 1)
                        _StoreProductsList(
                          products: storeProducts,
                          onProductTap: _openProduct,
                        )
                      else
                        const _StoreReviewsSection(),
                      SizedBox(height: height * 0.030),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header المتجر
class _StoreHeader extends StatelessWidget {
  final StoreModel store;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onToggleFavorite;

  const _StoreHeader({
    required this.store,
    required this.isFavorite,
    required this.onBack,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final headerHeight = height * 0.22;

    return Container(
      height: headerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [store.color, AppColors.navy.withOpacity(0.95)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.06,
          vertical: height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back + icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // back
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.15),
                    borderRadius: BorderRadius.circular(height * 0.014),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: onBack,
                  ),
                ),
                Icon(
                  Icons.storefront_outlined,
                  color: Colors.white.withOpacity(.92),
                  size: height * 0.032,
                ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: height * 0.065,
                  height: height * 0.065,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: height * 0.002,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    store.name.isNotEmpty ? store.name.characters.first : '?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: width * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: height * 0.024,
                        ),
                      ),
                      SizedBox(height: height * 0.004),
                      Text(
                        store.category,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(.88),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onToggleFavorite,
                  child: Container(
                    padding: EdgeInsets.all(height * 0.008),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border_rounded,
                      color: isFavorite ? Colors.redAccent : Colors.white,
                      size: height * 0.026,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreStatsRow extends StatelessWidget {
  final StoreModel store;

  const _StoreStatsRow({required this.store});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;

    return Row(
      children: [
        _StatChip(
          icon: Icons.star_rounded,
          label: store.rating.toStringAsFixed(1),
          subtitle: 'التقييم',
          color: Colors.amber,
        ),
        SizedBox(width: width * 0.04),
        _StatChip(
          icon: Icons.place_outlined,
          label: '${store.distanceKm.toStringAsFixed(1)} كم',
          subtitle: 'المسافة',
          color: AppColors.teal,
        ),
        SizedBox(width: width * 0.04),
        const _StatChip(
          icon: Icons.access_time_rounded,
          label: 'مفتوح',
          subtitle: 'الوقت الآن',
          color: AppColors.orange,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.02,
          vertical: height * 0.010,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(height * 0.018),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                theme.brightness == Brightness.light ? 0.04 : 0.20,
              ),
              blurRadius: height * 0.018,
              offset: Offset(0, height * 0.008),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: height * 0.032,
              height: height * 0.032,
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(height * 0.012),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: height * 0.020, color: color),
            ),
            SizedBox(width: width * 0.016),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: height * 0.002),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final height = size.height;

    return Row(
      children: [
        Container(
          width: height * 0.010,
          height: height * 0.010,
          decoration: BoxDecoration(
            color: AppColors.teal,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        SizedBox(width: size.width * 0.018),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
      ],
    );
  }
}

class _StoreTagsRow extends StatelessWidget {
  const _StoreTagsRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final height = size.height;
    final width = size.width;

    final tags = ['جلسات مريحة', 'مناسب للعمل', 'إنترنت سريع', 'Wi-Fi'];

    return Wrap(
      spacing: width * 0.020,
      runSpacing: height * 0.010,
      children: tags
          .map(
            (t) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.032,
                vertical: height * 0.006,
              ),
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.10),
                borderRadius: BorderRadius.circular(height * 0.016),
              ),
              child: Text(
                t,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.navy.withOpacity(0.85),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

/// تبويبات ريلز / منتجات / تقييمات
class _StoreTabs extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const _StoreTabs({required this.currentIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final height = size.height;
    final width = size.width;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(height * 0.004),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(height * 0.018),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.light ? 0.03 : 0.18,
            ),
            blurRadius: height * 0.016,
            offset: Offset(0, height * 0.006),
          ),
        ],
      ),
      child: Row(
        children: [
          _TabChip(
            label: 'ريلز المتجر',
            index: 0,
            currentIndex: currentIndex,
            onTap: onChanged,
          ),
          SizedBox(width: width * 0.012),
          _TabChip(
            label: 'المنتجات',
            index: 1,
            currentIndex: currentIndex,
            onTap: onChanged,
          ),
          SizedBox(width: width * 0.012),
          _TabChip(
            label: 'التقييمات',
            index: 2,
            currentIndex: currentIndex,
            onTap: onChanged,
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _TabChip({
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final height = size.height;
    final width = size.width;
    final theme = Theme.of(context);

    final selected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.018,
            vertical: height * 0.008,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.teal.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(height * 0.014),
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.navy : theme.hintColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// تبويب: ريلز المتجر (placeholder حالياً)
class _StoreReelsPlaceholder extends StatelessWidget {
  final StoreModel store;

  const _StoreReelsPlaceholder({required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final height = size.height;
    final width = size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(height * 0.018),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ريلز المتجر',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: height * 0.008),
          Text(
            'هنا رح تظهر ريلز المتجر (فيديوهات قصيرة / عروض سريعة) لما نربطها لاحقاً مع نظام المحتوى.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
          SizedBox(height: height * 0.016),
          Container(
            height: height * 0.18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height * 0.018),
              gradient: LinearGradient(
                colors: [
                  store.color.withOpacity(0.9),
                  store.color.withOpacity(0.6),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.play_circle_outline_rounded,
                color: Colors.white,
                size: height * 0.06,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// تبويب: منتجات المتجر
class _StoreProductsList extends StatelessWidget {
  final List<StoreProduct> products;
  final ValueChanged<StoreProduct> onProductTap;

  const _StoreProductsList({
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final height = size.height;
    final width = size.width;

    if (products.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(width * 0.04),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(height * 0.018),
        ),
        child: Text(
          'لا يوجد منتجات مضافة لهذا المتجر حالياً.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'منتجات المتجر'),
        SizedBox(height: height * 0.012),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          separatorBuilder: (_, __) => SizedBox(height: height * 0.010),
          itemBuilder: (context, index) {
            final product = products[index];
            return GestureDetector(
              onTap: () => onProductTap(product),
              child: Container(
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
                        theme.brightness == Brightness.light ? 0.03 : 0.18,
                      ),
                      blurRadius: height * 0.014,
                      offset: Offset(0, height * 0.006),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: height * 0.06,
                      height: height * 0.06,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            product.color.withOpacity(0.9),
                            product.color.withOpacity(0.6),
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        product.name.characters.first,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: height * 0.004),
                          Text(
                            product.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: width * 0.02),
                    Text(
                      '${product.price.toStringAsFixed(2)} د.أ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// تبويب: التقييمات (UI تجريبي حالياً)
class _StoreReviewsSection extends StatelessWidget {
  const _StoreReviewsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final height = size.height;
    final width = size.width;

    final reviews = _dummyReviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'التقييمات'),
        SizedBox(height: height * 0.012),
        if (reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(width * 0.04),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(height * 0.018),
            ),
            child: Text(
              'لم يتم إضافة أي تقييمات لهذا المتجر بعد.',
              style: theme.textTheme.bodyMedium,
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => SizedBox(height: height * 0.010),
            itemBuilder: (context, index) {
              final r = reviews[index];
              return Container(
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
                        theme.brightness == Brightness.light ? 0.03 : 0.18,
                      ),
                      blurRadius: height * 0.014,
                      offset: Offset(0, height * 0.006),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: height * 0.020,
                          backgroundColor: AppColors.teal.withOpacity(0.12),
                          child: Text(
                            r.userName.characters.first,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.teal,
                            ),
                          ),
                        ),
                        SizedBox(width: width * 0.02),
                        Expanded(
                          child: Text(
                            r.userName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 18,
                            ),
                            SizedBox(width: width * 0.006),
                            Text(
                              r.rating.toStringAsFixed(1),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.006),
                    Text(
                      r.comment,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.9,
                        ),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: height * 0.004),
                    Text(
                      r.dateLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

/// نموذج تقييم بسيط تجريبي
class _Review {
  final String userName;
  final double rating;
  final String comment;
  final String dateLabel;

  _Review({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.dateLabel,
  });
}

final List<_Review> _dummyReviews = [
  _Review(
    userName: 'أحمد خالد',
    rating: 4.8,
    comment: 'مكان رائع والقهوة ممتازة، الجو هادئ ومناسب للشغل.',
    dateLabel: 'قبل أسبوع',
  ),
  _Review(
    userName: 'سارة محمد',
    rating: 4.5,
    comment: 'الخدمة لطيفة جداً، بس في بعض الأوقات بيكون المكان مزدحم.',
    dateLabel: 'قبل 3 أيام',
  ),
];
