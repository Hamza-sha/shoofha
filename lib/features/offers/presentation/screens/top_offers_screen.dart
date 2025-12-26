import 'package:flutter/material.dart';
import 'package:shoofha/app/theme/app_theme.dart';
// ignore: unused_import
import 'package:shoofha/core/theme/app_colors.dart' hide AppColors;

enum OffersFilter { all, today, week, near, online }

class TopOffersScreen extends StatefulWidget {
  const TopOffersScreen({super.key});

  @override
  State<TopOffersScreen> createState() => _TopOffersScreenState();
}

class _TopOffersScreenState extends State<TopOffersScreen> {
  OffersFilter _selected = OffersFilter.all;

  // ✅ Dummy data (مصدر واحد للحقيقة داخل الشاشة)
  final List<_Offer> _offers = const [
    _Offer(
      id: 'o1',
      storeName: 'Coffee Mood',
      title: 'خصم 30% على المشروبات الباردة',
      tag: 'اليوم فقط',
      percentOff: 30,
      isToday: true,
      isOnline: false,
      distanceKm: 1.2,
      category: 'مطاعم وكافيهات',
      color: Color(0xFF3E2723),
    ),
    _Offer(
      id: 'o2',
      storeName: 'FitZone Gym',
      title: '3 شهور بسعر شهرين',
      tag: 'اشتراك جديد',
      percentOff: 33,
      isToday: false,
      isOnline: false,
      distanceKm: 3.5,
      category: 'رياضة وصحة',
      color: Color(0xFF1B5E20),
    ),
    _Offer(
      id: 'o3',
      storeName: 'Tech Corner',
      title: 'حتى 40% على الإكسسوارات',
      tag: 'الكترونيات',
      percentOff: 40,
      isToday: false,
      isOnline: true,
      distanceKm: 5.4,
      category: 'الكترونيات',
      color: Color(0xFF0D47A1),
    ),
    _Offer(
      id: 'o4',
      storeName: 'Rose Home',
      title: 'خصومات على الديكورات الجديدة',
      tag: 'جديد',
      percentOff: 25,
      isToday: false,
      isOnline: false,
      distanceKm: 2.1,
      category: 'ديكور منزلي',
      color: Color(0xFFB23A48),
    ),
  ];

  List<_Offer> get _filteredOffers {
    final list = [..._offers];

    switch (_selected) {
      case OffersFilter.all:
        return list;
      case OffersFilter.today:
        return list.where((o) => o.isToday).toList();
      case OffersFilter.week:
        // Dummy: الأسبوع = الكل ما عدا اليوم فقط
        return list.where((o) => !o.isToday).toList();
      case OffersFilter.near:
        final near = list.where((o) => o.distanceKm <= 3.0).toList();
        near.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        return near;
      case OffersFilter.online:
        return list.where((o) => o.isOnline).toList();
    }
  }

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(milliseconds: 1100),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final shoofhaTheme = theme.extension<ShoofhaTheme>();

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final horizontalPadding = width * 0.06;
    final vSpaceXs = height * 0.012;
    final vSpaceSm = height * 0.018;
    final vSpaceMd = height * 0.026;
    final vSpaceLg = height * 0.034;

    final results = _filteredOffers;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: height * 0.014,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أقوى العروض',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: vSpaceXs),
                    Text(
                      'اكتشف خصومات اليوم، العروض المحدودة، والصفقات القريبة منك.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: vSpaceSm),

                    _OffersFilterChips(
                      selected: _selected,
                      onSelected: (f) => setState(() => _selected = f),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: results.isEmpty
                        ? const _EmptyOffers()
                        : SingleChildScrollView(
                            key: ValueKey(
                              'offers-${_selected.name}-${results.length}',
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Hero Banner (واضح + CTA)
                                _TodayHighlightBanner(
                                  gradient:
                                      shoofhaTheme?.primaryButtonGradient ??
                                      LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.navy,
                                          AppColors.purple,
                                        ],
                                      ),
                                  onTap: () =>
                                      _toast('قريباً: صفحة عروض اليوم'),
                                ),
                                SizedBox(height: vSpaceMd),

                                _SectionHeader(
                                  title: 'عروض مختارة لك',
                                  onSeeAll: () => _toast('قريباً: عرض الكل'),
                                ),
                                SizedBox(height: vSpaceXs),

                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: results.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(height: height * 0.014),
                                  itemBuilder: (context, index) {
                                    final offer = results[index];
                                    return _OfferCard(
                                      offer: offer,
                                      onTap: () => _toast(
                                        'فتح تفاصيل العرض: ${offer.storeName}',
                                      ),
                                    );
                                  },
                                ),

                                SizedBox(height: vSpaceMd),

                                _SectionHeader(
                                  title: 'عروض حسب الفئة',
                                  onSeeAll: () => _toast('قريباً: صفحة الفئات'),
                                ),
                                SizedBox(height: vSpaceXs),

                                _OffersByCategoryGrid(
                                  onTap: (category) =>
                                      _toast('فتح عروض فئة: $category'),
                                ),

                                SizedBox(height: vSpaceLg),
                              ],
                            ),
                          ),
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

/// Header لكل سيكشن
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final height = MediaQuery.sizeOf(context).height;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: 0,
              vertical: height * 0.004,
            ),
            minimumSize: Size.zero,
          ),
          onPressed: onSeeAll,
          child: Text(
            'عرض الكل',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.secondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

/// Chips فلترة العروض (فعّالة)
class _OffersFilterChips extends StatelessWidget {
  final OffersFilter selected;
  final ValueChanged<OffersFilter> onSelected;

  const _OffersFilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    const filters = <(OffersFilter, String)>[
      (OffersFilter.all, 'الكل'),
      (OffersFilter.today, 'اليوم فقط'),
      (OffersFilter.week, 'هذا الأسبوع'),
      (OffersFilter.near, 'قريب منك'),
      (OffersFilter.online, 'أونلاين'),
    ];

    return SizedBox(
      height: height * 0.045,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: width * 0.02),
        itemBuilder: (context, index) {
          final f = filters[index].$1;
          final label = filters[index].$2;
          final isSelected = f == selected;

          return GestureDetector(
            onTap: () => onSelected(f),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.005,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height * 0.022),
                color: isSelected
                    ? cs.secondary
                    : cs.surfaceContainerHighest.withOpacity(
                        theme.brightness == Brightness.light ? 0.55 : 0.16,
                      ),
                border: Border.all(
                  color: cs.outline.withOpacity(isSelected ? 0.0 : 0.22),
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? cs.onSecondary
                        : cs.onSurface.withOpacity(0.85),
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Hero Banner
class _TodayHighlightBanner extends StatelessWidget {
  final Gradient gradient;
  final VoidCallback onTap;

  const _TodayHighlightBanner({required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final radius = height * 0.028;

    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: gradient,
        ),
        padding: EdgeInsets.all(width * 0.045),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'عروض اليوم فقط ⚡',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: height * 0.006),
                  Text(
                    'خصومات محدودة على أفضل المتاجر والمنتجات المختارة لك.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: height * 0.014),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.04,
                      vertical: height * 0.006,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(height * 0.020),
                    ),
                    child: Text(
                      'حتى 50% خصم على مختارات اليوم',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: width * 0.03),
            Container(
              width: height * 0.09,
              height: height * 0.09,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
              child: Center(
                child: Text(
                  '50%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Offer Card (عمودي — منظم)
class _OfferCard extends StatelessWidget {
  final _Offer offer;
  final VoidCallback onTap;

  const _OfferCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final radius = height * 0.024;

    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                theme.brightness == Brightness.light ? 0.03 : 0.28,
              ),
              blurRadius: height * 0.02,
              offset: Offset(0, height * 0.01),
            ),
          ],
        ),
        padding: EdgeInsets.all(width * 0.04),
        child: Row(
          children: [
            // Left: badge percent
            Container(
              width: width * 0.18,
              height: width * 0.18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    offer.color.withOpacity(0.95),
                    offer.color.withOpacity(0.75),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  '${offer.percentOff}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            SizedBox(width: width * 0.04),

            // Middle content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // tag
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.03,
                      vertical: height * 0.004,
                    ),
                    decoration: BoxDecoration(
                      color: cs.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(height * 0.018),
                    ),
                    child: Text(
                      offer.tag,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.secondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.008),
                  Text(
                    offer.storeName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: height * 0.004),
                  Text(
                    offer.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withOpacity(0.75),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: height * 0.008),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: height * 0.022,
                        color: cs.secondary,
                      ),
                      SizedBox(width: width * 0.01),
                      Text(
                        offer.isOnline
                            ? 'أونلاين'
                            : '${offer.distanceKm.toStringAsFixed(1)} كم',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface.withOpacity(0.75),
                        ),
                      ),
                      SizedBox(width: width * 0.02),
                      Container(
                        width: 1,
                        height: height * 0.018,
                        color: cs.outline.withOpacity(0.25),
                      ),
                      SizedBox(width: width * 0.02),
                      Text(
                        offer.category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right arrow
            Icon(
              Icons.chevron_left,
              size: height * 0.032,
              color: theme.iconTheme.color?.withOpacity(0.75),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid للفئات
class _OffersByCategoryGrid extends StatelessWidget {
  final ValueChanged<String> onTap;

  const _OffersByCategoryGrid({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final crossAxisCount = width >= 900 ? 3 : 2;
    final radius = height * 0.022;

    final categories = const [
      ('مطاعم وكافيهات', 'حتى 25%', Icons.restaurant_menu),
      ('موضة وأزياء', 'حتى 40%', Icons.checkroom_outlined),
      ('الكترونيات', 'حتى 35%', Icons.devices_other),
      ('الجمال والعناية', 'حتى 30%', Icons.brush_outlined),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: width * 0.04,
        mainAxisSpacing: height * 0.018,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final (title, discount, icon) = categories[index];

        return InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: () => onTap(title),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    theme.brightness == Brightness.light ? 0.03 : 0.28,
                  ),
                  blurRadius: height * 0.02,
                  offset: Offset(0, height * 0.01),
                ),
              ],
            ),
            padding: EdgeInsets.all(width * 0.035),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: height * 0.035, color: cs.secondary),
                SizedBox(height: height * 0.010),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: height * 0.006),
                Text(
                  discount,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'مشاهدة العروض',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.secondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyOffers extends StatelessWidget {
  const _EmptyOffers();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: w * 0.16,
              color: cs.onSurface.withOpacity(0.55),
            ),
            SizedBox(height: h * 0.015),
            Text(
              'ما في عروض حالياً',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: h * 0.008),
            Text(
              'جرّب تغيّر الفلتر، أو ارجع بعد شوي.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Model
class _Offer {
  final String id;
  final String storeName;
  final String title;
  final String tag;
  final int percentOff;
  final bool isToday;
  final bool isOnline;
  final double distanceKm;
  final String category;
  final Color color;

  const _Offer({
    required this.id,
    required this.storeName,
    required this.title,
    required this.tag,
    required this.percentOff,
    required this.isToday,
    required this.isOnline,
    required this.distanceKm,
    required this.category,
    required this.color,
  });
}
