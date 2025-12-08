import 'package:flutter/material.dart';
import 'package:shoofha/app/theme/app_theme.dart';

class TopOffersScreen extends StatelessWidget {
  const TopOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final horizontalPadding = width * 0.06;
    final vSpaceXs = height * 0.012;
    final vSpaceSm = height * 0.018;
    final vSpaceMd = height * 0.026;
    final vSpaceLg = height * 0.034;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // الهيدر
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: vSpaceXs),
                  Text(
                    'اكتشف خصومات اليوم، العروض المحدودة، والصفقات القريبة منك.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.7,
                      ),
                    ),
                  ),
                  SizedBox(height: vSpaceSm),

                  const _OffersFilterChips(),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // بانر رئيسي لعروض اليوم
                      const _TodayHighlightBanner(),
                      SizedBox(height: vSpaceMd),

                      // سيكشن: عروض مشتعلة 🔥
                      _SectionHeader(
                        title: 'عروض مشتعلة',
                        onSeeAll: () {
                          // TODO: صفحة كل العروض الساخنة
                        },
                      ),
                      SizedBox(height: vSpaceXs),
                      SizedBox(
                        height: height * 0.23,
                        child: const _HotOffersList(),
                      ),

                      SizedBox(height: vSpaceMd),

                      // سيكشن: عروض حسب الفئات
                      _SectionHeader(title: 'عروض حسب الفئة', onSeeAll: () {}),
                      SizedBox(height: vSpaceXs),

                      const _OffersByCategoryGrid(),

                      SizedBox(height: vSpaceLg),
                    ],
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

/// الهيدر الصغير لكل سيكشن
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final height = MediaQuery.sizeOf(context).height;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
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
              color: colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Chips فلترة العروض (اليوم، هذا الأسبوع، قريب، أونلاين...)
class _OffersFilterChips extends StatefulWidget {
  const _OffersFilterChips();

  @override
  State<_OffersFilterChips> createState() => _OffersFilterChipsState();
}

class _OffersFilterChipsState extends State<_OffersFilterChips> {
  int _selectedIndex = 0;

  final _filters = const [
    'الكل',
    'اليوم فقط',
    'هذا الأسبوع',
    'قريب منك',
    'أونلاين',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    return SizedBox(
      height: height * 0.045,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => SizedBox(width: width * 0.02),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedIndex;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = index);
              // TODO: ربط الفلتر مع البيانات الفعلية
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.005,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height * 0.022),
                color: isSelected
                    ? theme.colorScheme.secondary
                    : theme.chipTheme.backgroundColor,
              ),
              child: Center(
                child: Text(
                  _filters[index],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? theme.chipTheme.secondaryLabelStyle?.color ??
                              Colors.white
                        : theme.chipTheme.labelStyle?.color ??
                              theme.textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

/// بانر رئيسي لعروض اليوم فقط
class _TodayHighlightBanner extends StatelessWidget {
  const _TodayHighlightBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shoofhaTheme = theme.extension<ShoofhaTheme>();
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final radius = height * 0.028;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient:
            shoofhaTheme?.primaryButtonGradient ??
            const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navy, AppColors.purple],
            ),
      ),
      padding: EdgeInsets.all(width * 0.045),
      child: Row(
        children: [
          // نص العرض
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عروض اليوم فقط ⚡',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: height * 0.006),
                Text(
                  'لا تفوّت الخصومات المحدودة على أفضل المتاجر والمنتجات المختارة لك.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.85),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: width * 0.03),

          // دائرة فيها نسبة الخصم
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
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// قائمة أفقية لعروض مشتعلة
class _HotOffersList extends StatelessWidget {
  const _HotOffersList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final radius = height * 0.024;

    final offers = const [
      _OfferCardData(
        storeName: 'Coffee Mood',
        title: 'خصم 30% على المشروبات الباردة',
        tag: 'اليوم فقط',
        percentOff: 30,
        color: Color(0xFF3E2723),
      ),
      _OfferCardData(
        storeName: 'FitZone Gym',
        title: '3 شهور بسعر شهرين',
        tag: 'اشتراك جديد',
        percentOff: 33,
        color: Color(0xFF1B5E20),
      ),
      _OfferCardData(
        storeName: 'Tech Corner',
        title: 'حتى 40% على الإكسسوارات',
        tag: 'الكترونيات',
        percentOff: 40,
        color: Color(0xFF0D47A1),
      ),
    ];

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: offers.length,
      separatorBuilder: (_, __) => SizedBox(width: width * 0.04),
      itemBuilder: (context, index) {
        final offer = offers[index];
        return Container(
          width: width * 0.70,
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
          padding: EdgeInsets.all(width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // تاج العرض
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.03,
                  vertical: height * 0.004,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(height * 0.018),
                ),
                child: Text(
                  offer.tag,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: height * 0.010),
              Text(
                offer.storeName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: height * 0.004),
              Text(
                offer.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${offer.percentOff}%',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'تفاصيل العرض',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OfferCardData {
  final String storeName;
  final String title;
  final String tag;
  final int percentOff;
  final Color color;

  const _OfferCardData({
    required this.storeName,
    required this.title,
    required this.tag,
    required this.percentOff,
    required this.color,
  });
}

/// Grid لعروض حسب الفئة (مطاعم، موضة، إلكترونيات...)
class _OffersByCategoryGrid extends StatelessWidget {
  const _OffersByCategoryGrid();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

        return Container(
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
              Icon(
                icon,
                size: height * 0.035,
                color: theme.colorScheme.secondary,
              ),
              SizedBox(height: height * 0.010),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: height * 0.006),
              Text(
                discount,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'مشاهدة العروض',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
