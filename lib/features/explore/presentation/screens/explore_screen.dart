import 'package:flutter/material.dart';
import 'package:shoofha/core/theme/app_colors.dart';

enum ExploreFilter { all, near, topRated, newest, recommended }

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  ExploreFilter _selectedFilter = ExploreFilter.all;

  String get _query => _searchController.text.trim().toLowerCase();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFiltersSheet() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            w * 0.06,
            h * 0.015,
            w * 0.06,
            h * 0.02 + MediaQuery.of(context).viewPadding.bottom,
          ),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(h * 0.03)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  theme.brightness == Brightness.light ? 0.08 : 0.55,
                ),
                blurRadius: h * 0.03,
                offset: Offset(0, -h * 0.01),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: w * 0.12,
                height: h * 0.006,
                decoration: BoxDecoration(
                  color: cs.onSurface.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              SizedBox(height: h * 0.02),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'فلاتر',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: h * 0.01),
              Text(
                'قريباً رح نخليها فلترة متقدمة (تصنيف، سعر، تقييم، مسافة).',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.7),
                ),
              ),
              SizedBox(height: h * 0.02),
              SizedBox(
                width: double.infinity,
                height: h * 0.06,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'تمام',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final horizontalPadding = width * 0.06;
    final vSpaceXs = height * 0.012;
    final vSpaceSm = height * 0.018;
    final vSpaceMd = height * 0.026;
    final vSpaceLg = height * 0.034;

    // ✅ Dummy Data (مخزون واحد نفلتر منه)
    final collections = const [
      _CollectionItem('موضة وأزياء', Icons.checkroom_outlined),
      _CollectionItem('المطاعم والكافيهات', Icons.restaurant_menu),
      _CollectionItem('الكترونيات وتقنية', Icons.devices_other),
      _CollectionItem('الجمال والعناية', Icons.brush_outlined),
    ];

    final reels = const [
      _ReelItem('Coffee Mood', 'خصم على المشروبات الباردة', AppColors.navy),
      _ReelItem('FitZone Gym', 'اشتراك + شهر مجاناً', AppColors.purple),
      _ReelItem('Tech Corner', 'عروض باور بانك وسماعات', AppColors.teal),
      _ReelItem('Rose Home', 'ديكورات جديدة للبيت', Color(0xFFB23A48)),
      _ReelItem('Gifts Box', 'هدايا جاهزة لكل مناسبة', Color(0xFF3D155F)),
      _ReelItem('Burger Hub', 'برجر مع عرض مميز', Color(0xFFBF360C)),
    ];

    final stores = const [
      _StoreItem('Coffee Mood', 'كافيه', 1.2, 4.7),
      _StoreItem('FitZone Gym', 'نادي رياضي', 3.5, 4.5),
      _StoreItem('Tech Corner', 'الكترونيات', 5.4, 4.3),
      _StoreItem('Rose Home Decor', 'ديكور منزلي', 2.1, 4.8),
    ];

    // ✅ Apply Search
    bool matchText(String value) {
      if (_query.isEmpty) return true;
      return value.toLowerCase().contains(_query);
    }

    var filteredCollections = collections
        .where((c) => matchText(c.title))
        .toList();
    var filteredReels = reels
        .where((r) => matchText(r.store) || matchText(r.title))
        .toList();
    var filteredStores = stores
        .where((s) => matchText(s.name) || matchText(s.category))
        .toList();

    // ✅ Apply Filter (منطقي/تجريبي)
    switch (_selectedFilter) {
      case ExploreFilter.all:
        break;
      case ExploreFilter.near:
        filteredStores = filteredStores
          ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case ExploreFilter.topRated:
        filteredStores = filteredStores
          ..sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ExploreFilter.newest:
        // Dummy: خليناها تعكس ترتيب الريلز
        filteredReels = filteredReels.reversed.toList();
        break;
      case ExploreFilter.recommended:
        // Dummy: خليها تتجه للـ reels أكثر
        if (filteredStores.length > 2) {
          filteredStores = filteredStores.take(2).toList();
        }
        break;
    }

    final hasAnyResults =
        filteredCollections.isNotEmpty ||
        filteredReels.isNotEmpty ||
        filteredStores.isNotEmpty;

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

                    _ExploreSearchBar(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      onClear: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      onOpenFilters: _openFiltersSheet,
                    ),
                    SizedBox(height: vSpaceSm),

                    _ExploreFilterChips(
                      selected: _selectedFilter,
                      onSelected: (f) => setState(() => _selectedFilter = f),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: !hasAnyResults
                        ? _EmptyExplore(query: _searchController.text.trim())
                        : SingleChildScrollView(
                            key: ValueKey(
                              'content-$_query-${_selectedFilter.name}',
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: vSpaceSm),

                                if (filteredCollections.isNotEmpty) ...[
                                  Text(
                                    'مجموعات مقترحة',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(height: vSpaceXs),
                                  SizedBox(
                                    height: height * 0.20,
                                    child: _ExploreCollectionsList(
                                      items: filteredCollections,
                                    ),
                                  ),
                                  SizedBox(height: vSpaceMd),
                                ],

                                if (filteredReels.isNotEmpty) ...[
                                  Text(
                                    'استكشف الريلز',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(height: vSpaceXs),
                                  _ExploreReelsGrid(items: filteredReels),
                                  SizedBox(height: vSpaceMd),
                                ],

                                if (filteredStores.isNotEmpty) ...[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'متاجر قريبة منك',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // TODO: صفحة كل المتاجر
                                        },
                                        child: Text(
                                          'عرض الكل',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: cs.secondary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: vSpaceXs),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: filteredStores.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: height * 0.014),
                                    itemBuilder: (context, index) {
                                      return _NearbyStoreTile(
                                        item: filteredStores[index],
                                      );
                                    },
                                  ),
                                ],

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

/// Search Bar
class _ExploreSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onOpenFilters;

  const _ExploreSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.onOpenFilters,
  });

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
              controller: controller,
              onChanged: onChanged,
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

          if (controller.text.trim().isNotEmpty) ...[
            SizedBox(width: width * 0.01),
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onClear,
              child: Padding(
                padding: EdgeInsets.all(height * 0.006),
                child: Icon(
                  Icons.close,
                  size: height * 0.022,
                  color: theme.iconTheme.color?.withOpacity(0.85),
                ),
              ),
            ),
          ],

          SizedBox(width: width * 0.01),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onOpenFilters,
            child: Padding(
              padding: EdgeInsets.all(height * 0.006),
              child: Icon(
                Icons.tune,
                size: height * 0.024,
                color: theme.iconTheme.color?.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter Chips
class _ExploreFilterChips extends StatelessWidget {
  final ExploreFilter selected;
  final ValueChanged<ExploreFilter> onSelected;

  const _ExploreFilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    const filters = <(ExploreFilter, String)>[
      (ExploreFilter.all, 'الكل'),
      (ExploreFilter.near, 'قريب منك'),
      (ExploreFilter.topRated, 'تقييم عالي'),
      (ExploreFilter.newest, 'جديد'),
      (ExploreFilter.recommended, 'موصى به لك'),
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

/// Collections List
class _ExploreCollectionsList extends StatelessWidget {
  final List<_CollectionItem> items;

  const _ExploreCollectionsList({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final radius = height * 0.026;

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(width: width * 0.04),
      itemBuilder: (context, index) {
        final item = items[index];

        final gradient = index.isEven
            ? const LinearGradient(colors: [AppColors.navy, AppColors.purple])
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.secondary,
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
                Icon(item.icon, size: height * 0.04, color: Colors.white),
                SizedBox(height: height * 0.012),
                Text(
                  item.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
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
                      fontWeight: FontWeight.w700,
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

/// Reels Grid
class _ExploreReelsGrid extends StatelessWidget {
  final List<_ReelItem> items;

  const _ExploreReelsGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final crossAxisCount = width >= 900 ? 4 : (width >= 600 ? 3 : 2);
    final radius = height * 0.028;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: width * 0.02,
        mainAxisSpacing: height * 0.012,
        childAspectRatio: 9 / 16,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _ReelPreviewCard(
          radius: radius,
          storeName: item.store,
          title: item.title,
          baseColor: item.color,
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
          Padding(
            padding: EdgeInsets.all(width * 0.025),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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
                            fontWeight: FontWeight.w700,
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
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {
                  // TODO: افتح شاشة ريلز كاملة لاحقاً
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Store Tile
class _NearbyStoreTile extends StatelessWidget {
  final _StoreItem item;

  const _NearbyStoreTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final radius = height * 0.022;

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
                  item.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: height * 0.004),
                Text(
                  item.category,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
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
                      item.rating.toStringAsFixed(1),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: width * 0.02),
                    Icon(
                      Icons.location_on_outlined,
                      size: height * 0.022,
                      color: cs.secondary,
                    ),
                    Text(
                      '${item.distanceKm.toStringAsFixed(1)} كم',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.8,
                        ),
                        fontWeight: FontWeight.w600,
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

class _EmptyExplore extends StatelessWidget {
  final String query;

  const _EmptyExplore({required this.query});

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
              Icons.search_off_rounded,
              size: w * 0.16,
              color: cs.onSurface.withOpacity(0.55),
            ),
            SizedBox(height: h * 0.015),
            Text(
              'ما في نتائج',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: h * 0.008),
            Text(
              query.isEmpty
                  ? 'جرّب تدور على متجر أو منتج.'
                  : 'ما لقينا نتائج لـ "$query".',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Models
class _CollectionItem {
  final String title;
  final IconData icon;
  const _CollectionItem(this.title, this.icon);
}

class _ReelItem {
  final String store;
  final String title;
  final Color color;
  const _ReelItem(this.store, this.title, this.color);
}

class _StoreItem {
  final String name;
  final String category;
  final double distanceKm;
  final double rating;
  const _StoreItem(this.name, this.category, this.distanceKm, this.rating);
}
