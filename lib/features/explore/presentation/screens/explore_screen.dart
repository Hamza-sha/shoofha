import 'package:flutter/material.dart';
import 'package:shoofha/app/theme/app_theme.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

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
            // الهيدر: عنوان + بحث
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: height * 0.014,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'استكشاف',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: vSpaceXs),
                  Text(
                    'اكتشف متاجر جديدة، تصنيفات، وريلز تشبه اهتماماتك.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.7,
                      ),
                    ),
                  ),
                  SizedBox(height: vSpaceSm),

                  // حقل البحث
                  _ExploreSearchBar(),
                  SizedBox(height: vSpaceSm),

                  // Chips للفلاتر
                  const _ExploreFilterChips(),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: vSpaceSm),

                      // سيكشن: Collections / Topics
                      Text(
                        'مجموعات مقترحة',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: vSpaceXs),
                      SizedBox(
                        height: height * 0.20,
                        child: const _ExploreCollectionsList(),
                      ),

                      SizedBox(height: vSpaceMd),

                      // ✅ سيكشن جديد: ريلز الاستكشاف (زي إنستا)
                      Text(
                        'استكشف الريلز',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: vSpaceXs),

                      const _ExploreReelsGrid(),

                      SizedBox(height: vSpaceMd),

                      // سيكشن: متاجر قريبة
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'متاجر قريبة منك',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: صفحة كل المتاجر
                            },
                            child: Text(
                              'عرض الكل',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: vSpaceXs),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: height * 0.014),
                        itemBuilder: (context, index) {
                          return _NearbyStoreTile(index: index);
                        },
                      ),

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

/// حقل البحث في الاستكشاف
class _ExploreSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final radius = height * 0.022;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.light ? 0.03 : 0.4,
            ),
            blurRadius: height * 0.02,
            offset: Offset(0, height * 0.008),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.006,
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: height * 0.026,
            color: theme.iconTheme.color?.withOpacity(0.9),
          ),
          SizedBox(width: width * 0.02),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'ابحث عن متجر، منتج أو ريل...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
              ),
            ),
          ),
          SizedBox(width: width * 0.02),
          Icon(
            Icons.tune,
            size: height * 0.024,
            color: theme.iconTheme.color?.withOpacity(0.9),
          ),
        ],
      ),
    );
  }
}

/// Chips للفلاتر (كل شيء، قريب، تقييم عالي، جديد... الخ)
class _ExploreFilterChips extends StatefulWidget {
  const _ExploreFilterChips();

  @override
  State<_ExploreFilterChips> createState() => _ExploreFilterChipsState();
}

class _ExploreFilterChipsState extends State<_ExploreFilterChips> {
  int _selectedIndex = 0;

  final _filters = const [
    'الكل',
    'قريب منك',
    'تقييم عالي',
    'جديد',
    'موصى به لك',
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
              // TODO: فعليًا طبّق الفلتر على النتائج
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

/// سكشن مجموعات (Collections)
class _ExploreCollectionsList extends StatelessWidget {
  const _ExploreCollectionsList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shoofhaTheme = theme.extension<ShoofhaTheme>();
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final collections = const [
      ('موضة وأزياء', Icons.checkroom_outlined),
      ('المطاعم والكافيهات', Icons.restaurant_menu),
      ('الكترونيات وتقنية', Icons.devices_other),
      ('الجمال والعناية', Icons.brush_outlined),
    ];

    final radius = height * 0.026;

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: collections.length,
      separatorBuilder: (_, __) => SizedBox(width: width * 0.04),
      itemBuilder: (context, index) {
        final (title, iconData) = collections[index];

        final gradient = index.isEven
            ? (shoofhaTheme?.primaryButtonGradient ??
                  const LinearGradient(
                    colors: [AppColors.navy, AppColors.purple],
                  ))
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.secondary,
                  AppColors.purple.withOpacity(0.9),
                ],
              );

        return Container(
          width: width * 0.60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: gradient,
          ),
          child: Padding(
            padding: EdgeInsets.all(width * 0.045),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(iconData, size: height * 0.04, color: Colors.white),
                SizedBox(height: height * 0.012),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: height * 0.006),
                Text(
                  'اكتشف متاجر ومنتجات مختارة بعناية ضمن هذا القسم.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'استكشاف الآن',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

/// ✅ Grid ريلز الاستكشاف (زي إنستا)
class _ExploreReelsGrid extends StatelessWidget {
  const _ExploreReelsGrid();

  @override
  Widget build(BuildContext context) {
    final _ = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    // لو الشاشة أوسع (تابلت/ويب) بنزود عدد الأعمدة
    final crossAxisCount = width >= 900 ? 4 : (width >= 600 ? 3 : 2);

    final radius = height * 0.028;

    // Dummy data بسيطة للريلز
    final reels = const [
      ('Coffee Mood', 'خصم على المشروبات الباردة', AppColors.navy),
      ('FitZone Gym', 'اشتراك + شهر مجاناً', AppColors.purple),
      ('Tech Corner', 'عروض باور بانك وسماعات', AppColors.teal),
      ('Rose Home', 'ديكورات جديدة للبيت', Color(0xFFB23A48)),
      ('Gifts Box', 'هدايا جاهزة لكل مناسبة', Color(0xFF3D155F)),
      ('Burger Hub', 'برجر مع عرض مميز', Color(0xFFBF360C)),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: reels.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: width * 0.02,
        mainAxisSpacing: height * 0.012,
        childAspectRatio: 9 / 16, // شكل ريل vertical
      ),
      itemBuilder: (context, index) {
        final (store, title, color) = reels[index];
        return _ReelPreviewCard(
          radius: radius,
          storeName: store,
          title: title,
          baseColor: color,
        );
      },
    );
  }
}

class _ReelPreviewCard extends StatelessWidget {
  final double radius;
  final String storeName;
  final String title;
  final Color baseColor;

  const _ReelPreviewCard({
    required this.radius,
    required this.storeName,
    required this.title,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          // خلفية gradient تشبه فيديو
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  baseColor.withOpacity(0.95),
                  baseColor.withOpacity(0.6),
                ],
              ),
            ),
          ),

          // تدرج اسود/شفاف للنص
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.30),
                  Colors.transparent,
                  Colors.black.withOpacity(0.65),
                ],
              ),
            ),
          ),

          // محتوى داخل الكرت
          Padding(
            padding: EdgeInsets.all(width * 0.025),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم المتجر فوق
                Text(
                  storeName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),

                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: height * 0.004),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: width * 0.01),
                        Text(
                          'رييل',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.volume_mute,
                      color: Colors.white.withOpacity(0.9),
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // GestureDetector لو حابين لاحقاً نفتح شاشة ريلز كاملة
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {
                  // TODO: افتح شاشة ريلز كاملة
                  // ممكن تعيد استخدام HomeScreen بتعديل بسيط (نمرر index)
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// عنصر لمتجر قريب
class _NearbyStoreTile extends StatelessWidget {
  final int index;

  const _NearbyStoreTile({required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final radius = height * 0.022;

    final storeName = [
      'Coffee Mood',
      'FitZone Gym',
      'Tech Corner',
      'Rose Home Decor',
    ][index % 4];

    final category = [
      'كافيه',
      'نادي رياضي',
      'الكترونيات',
      'ديكور منزلي',
    ][index % 4];

    final distanceKm = [1.2, 3.5, 5.4, 2.1][index % 4];
    final rating = [4.7, 4.5, 4.3, 4.8][index % 4];

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
      child: Row(
        children: [
          // صورة مصغرة Placeholder
          Container(
            width: height * 0.07,
            height: height * 0.07,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius * 0.8),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.navy, AppColors.purple],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.storefront,
                color: Colors.white,
                size: height * 0.032,
              ),
            ),
          ),
          SizedBox(width: width * 0.04),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: height * 0.004),
                Text(
                  category,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: height * 0.004),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: height * 0.022,
                      color: Colors.amber,
                    ),
                    SizedBox(width: width * 0.008),
                    Text(
                      rating.toStringAsFixed(1),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: width * 0.02),
                    Icon(
                      Icons.location_on_outlined,
                      size: height * 0.022,
                      color: colorScheme.secondary,
                    ),
                    Text(
                      '${distanceKm.toStringAsFixed(1)} كم',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Icon(
            Icons.chevron_left,
            size: height * 0.030,
            color: theme.iconTheme.color?.withOpacity(0.8),
          ),
        ],
      ),
    );
  }
}
