import 'package:flutter/material.dart';
import 'package:shoofha/core/theme/app_colors.dart';
import 'package:shoofha/features/store/domain/store_models.dart';

/// ?? ???? ???? ??????? ?? ??????
Widget _backButton(BuildContext context) {
  final height = MediaQuery.sizeOf(context).height;

  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.15),
      borderRadius: BorderRadius.circular(height * 0.014),
    ),
    child: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
      onPressed: () => Navigator.of(context).maybePop(),
    ),
  );
}

class StoreProfileScreen extends StatelessWidget {
  const StoreProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ?????? ?????? ??? ???? ?? kStores ??????
    final store = kStores.first;
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final horizontalPadding = width * 0.06;
    final vSpaceMd = height * 0.024;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _StoreHeader(store: store),
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
                    const _SectionTitle(title: '?? ??????'),
                    SizedBox(height: height * 0.008),
                    Text(
                      '???? ${store.category} ?? ?????? ?? ????? ????? ??????? ?????? ????? ?? ???????.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.85,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.024),
                    const _SectionTitle(title: '??????? ????????'),
                    SizedBox(height: height * 0.012),
                    const _StoreTagsRow(),
                    SizedBox(height: height * 0.024),
                    const _SectionTitle(title: '?????? ??????'),
                    SizedBox(height: height * 0.012),
                    _HorizontalProductsPlaceholder(height: height),
                    SizedBox(height: height * 0.030),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreHeader extends StatelessWidget {
  final StoreModel store;

  const _StoreHeader({required this.store});

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
            // Back + store icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _backButton(context),
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
                Icon(
                  Icons.favorite_border_rounded,
                  color: Colors.white.withOpacity(.95),
                  size: height * 0.026,
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
          subtitle: '???????',
          color: Colors.amber,
        ),
        SizedBox(width: width * 0.04),
        _StatChip(
          icon: Icons.place_outlined,
          label: '${store.distanceKm.toStringAsFixed(1)} ??',
          subtitle: '???????',
          color: AppColors.teal,
        ),
        SizedBox(width: width * 0.04),
        const _StatChip(
          icon: Icons.access_time_rounded,
          label: '?????',
          subtitle: '?????',
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

    final tags = ['????? ??????', '????? ?????', '?????? ?????', 'Wi-Fi'];

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

class _HorizontalProductsPlaceholder extends StatelessWidget {
  final double height;

  const _HorizontalProductsPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;

    return SizedBox(
      height: height * 0.18,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(width: width * 0.03),
        itemBuilder: (_, index) {
          return Container(
            width: width * 0.48,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(height * 0.020),
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
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.030,
                vertical: height * 0.012,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '???? ???? ${index + 1}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: height * 0.006),
                  Text(
                    '??? ???? ?? ?????? ???? ???.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(
                        0.75,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '4.50 ?.?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
