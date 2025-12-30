import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/core/responsive/responsive.dart';
import 'package:shoofha/core/theme/app_colors.dart';
import 'package:shoofha/core/auth/guest_guard.dart';
import 'package:shoofha/features/social/application/reactions_controller.dart';

// ✅ NEW: Feed
import 'package:shoofha/features/feed/application/feed_controller.dart';
import 'package:shoofha/features/feed/application/feed_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // ✅ Controller لكل Mode عشان نحفظ الـ index ونمنع jump
  late final PageController _forYouController;
  late final PageController _followingController;
  late final PageController _searchController;

  // ✅ مؤقت: بدنا نربطه لاحقاً بالـ messages_controller
  final int _unreadCountMock = 3;

  @override
  void initState() {
    super.initState();
    _forYouController = PageController();
    _followingController = PageController();
    _searchController = PageController();
  }

  @override
  void dispose() {
    _forYouController.dispose();
    _followingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  PageController _controllerForMode(FeedMode mode) {
    return switch (mode) {
      FeedMode.forYou => _forYouController,
      FeedMode.following => _followingController,
      FeedMode.search => _searchController,
    };
  }

  String _formatLikes(int value) {
    if (value >= 1000) {
      final double k = value / 1000;
      return '${k.toStringAsFixed(k % 1 == 0 ? 0 : 1)}K';
    }
    return value.toString();
  }

  bool _isLiked(FeedReel reel) => ref
      .watch(reactionsControllerProvider)
      .likedStoreIds
      .contains(reel.storeId);

  bool _isSaved(FeedReel reel) => ref
      .watch(reactionsControllerProvider)
      .savedStoreIds
      .contains(reel.storeId);

  bool _isFollowingStore(String storeId) =>
      ref.watch(feedControllerProvider).followingStoreIds.contains(storeId);

  Future<void> _toggleLike(FeedReel reel, BuildContext context) async {
    final allowed = await requireLogin(context);
    if (!allowed) return;
    if (!mounted) return;

    HapticFeedback.lightImpact();
    ref.read(reactionsControllerProvider.notifier).toggleLike(reel.storeId);
  }

  Future<void> _toggleSave(FeedReel reel, BuildContext context) async {
    final allowed = await requireLogin(context);
    if (!allowed) return;
    if (!mounted) return;

    HapticFeedback.lightImpact();
    ref.read(reactionsControllerProvider.notifier).toggleSave(reel.storeId);
  }

  Future<void> _toggleFollow(FeedReel reel, BuildContext context) async {
    final allowed = await requireLogin(context);
    if (!allowed) return;
    if (!mounted) return;

    HapticFeedback.selectionClick();

    final current = ref.read(feedControllerProvider).followingStoreIds;
    final next = {...current};

    final isFollowing = next.contains(reel.storeId);
    if (isFollowing) {
      next.remove(reel.storeId);
    } else {
      next.add(reel.storeId);
    }

    ref.read(feedControllerProvider.notifier).setFollowingStores(next);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFollowing ? 'تم إلغاء متابعة المتجر' : 'تمت متابعة المتجر ✅',
        ),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openStore(FeedReel reel, BuildContext context) {
    context.pushNamed('store', pathParameters: {'id': reel.storeId});
  }

  void _openShareSheet(BuildContext context, FeedReel reel) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final h = Responsive.height(context);
    final w = Responsive.width(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final radius = h * 0.03;

        return Container(
          padding: EdgeInsets.fromLTRB(
            w * 0.06,
            h * 0.015,
            w * 0.06,
            h * 0.02 + MediaQuery.of(context).viewPadding.bottom,
          ),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  theme.brightness == Brightness.light ? 0.08 : 0.5,
                ),
                blurRadius: h * 0.03,
                offset: Offset(0, -h * 0.01),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: w * 0.12,
                  height: h * 0.006,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              SizedBox(height: h * 0.02),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'مشاركة',
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
              Text(
                'شارك عرض "${reel.storeName}" مع أصحابك.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.7),
                ),
              ),
              SizedBox(height: h * 0.02),
              Row(
                children: [
                  Expanded(
                    child: _ShareAction(
                      label: 'نسخ الرابط',
                      icon: Icons.link,
                      onTap: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم نسخ الرابط'),
                            duration: Duration(milliseconds: 900),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                  Expanded(
                    child: _ShareAction(
                      label: 'واتساب',
                      icon: Icons.chat_bubble_outline,
                      onTap: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('قريباً'),
                            duration: Duration(milliseconds: 900),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.015),
              Row(
                children: [
                  Expanded(
                    child: _ShareAction(
                      label: 'انستغرام',
                      icon: Icons.camera_alt_outlined,
                      onTap: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('قريباً'),
                            duration: Duration(milliseconds: 900),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                  Expanded(
                    child: _ShareAction(
                      label: 'المزيد',
                      icon: Icons.more_horiz,
                      onTap: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('قريباً'),
                            duration: Duration(milliseconds: 900),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.01),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedPage({
    required BuildContext context,
    required List<FeedReel> reels,
    required PageController controller,
    required double paddingTop,
  }) {
    final h = Responsive.height(context);
    final w = Responsive.width(context);
    final theme = Theme.of(context);

    return PageView.builder(
      key: PageStorageKey<String>('feed_${controller.hashCode}'),
      controller: controller,
      scrollDirection: Axis.vertical,
      itemCount: reels.length,
      itemBuilder: (context, index) {
        final reel = reels[index];
        final isLiked = _isLiked(reel);
        final isSaved = _isSaved(reel);
        final isFollowing = _isFollowingStore(reel.storeId);

        return Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                reel.color.withValues(alpha: 0.85),
                Colors.black.withValues(alpha: 0.96),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: w * 0.04,
              right: w * 0.04,
              bottom: h * 0.04,
              top: paddingTop + h * 0.09,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // معلومات المتجر + العرض
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _openStore(reel, context),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  reel.storeName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                SizedBox(height: h * 0.004),
                                Text(
                                  reel.category,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.80),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: w * 0.02),

                            // ✅ Follow button (داخل الريل)
                            _FollowChip(
                              isFollowing: isFollowing,
                              onTap: () => _toggleFollow(reel, context),
                            ),

                            SizedBox(width: w * 0.02),
                            CircleAvatar(
                              radius: h * 0.022,
                              backgroundColor: Colors.white,
                              child: Text(
                                reel.storeInitial,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navy,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: h * 0.016),
                        Text(
                          reel.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: h * 0.008),
                        Text(
                          reel.subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.90),
                          ),
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: h * 0.012),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.028,
                                vertical: h * 0.006,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(h * 0.016),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${reel.distanceKm.toStringAsFixed(1)} كم',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: w * 0.008),
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: h * 0.02,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: w * 0.02),
                            Flexible(
                              child: Text(
                                reel.priceLabel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: h * 0.02),

                        // CTA
                        GestureDetector(
                          onTap: () => _openStore(reel, context),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: h * 0.015),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [AppColors.teal, AppColors.purple],
                              ),
                              borderRadius: BorderRadius.circular(h * 0.02),
                            ),
                            child: Center(
                              child: Text(
                                reel.cta,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: w * 0.04),

                // أزرار التفاعل
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CircleIconButton(
                      icon: isLiked ? Icons.favorite : Icons.favorite_border,
                      isActive: isLiked,
                      onTap: () => _toggleLike(reel, context),
                      label: _formatLikes(reel.likes),
                      activeColor: Colors.redAccent,
                    ),
                    SizedBox(height: h * 0.018),
                    _CircleIconButton(
                      icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                      isActive: isSaved,
                      onTap: () => _toggleSave(reel, context),
                      label: _formatLikes(reel.saves),
                      activeColor: AppColors.teal,
                    ),
                    SizedBox(height: h * 0.018),
                    _CircleIconButton(
                      icon: Icons.share_outlined,
                      isActive: false,
                      onTap: () async {
                        HapticFeedback.selectionClick();
                        _openShareSheet(context, reel);
                      },
                      label: 'مشاركة',
                      activeColor: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = Responsive.height(context);
    final w = Responsive.width(context);
    final theme = Theme.of(context);
    final paddingTop = MediaQuery.of(context).padding.top;

    final feedState = ref.watch(feedControllerProvider);
    final reels = feedState.reels;
    final controller = _controllerForMode(feedState.mode);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // ✅ Background ثابت (منع أبيض)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.purple, Colors.black],
                  ),
                ),
              ),
            ),

            // ✅ Smooth switching بين التابات
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Builder(
                  key: ValueKey(feedState.mode),
                  builder: (_) {
                    if (reels.isEmpty && feedState.isLoading) {
                      return Center(
                        child: SizedBox(
                          height: h * 0.05,
                          width: h * 0.05,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }

                    if (reels.isEmpty && feedState.mode == FeedMode.following) {
                      return _EmptyFollowingState(paddingTop: paddingTop);
                    }

                    if (reels.isEmpty) {
                      return _EmptyExploreState(paddingTop: paddingTop);
                    }

                    return _buildFeedPage(
                      context: context,
                      reels: reels,
                      controller: controller,
                      paddingTop: paddingTop,
                    );
                  },
                ),
              ),
            ),

            // Header أعلى الشاشة
            Positioned(
              top: paddingTop + h * 0.015,
              left: w * 0.04,
              right: w * 0.04,
              child: Row(
                children: [
                  Text(
                    'Shoofha',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.all(h * 0.006),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(h * 0.018),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TopTabChip(
                          label: 'المتابَعون',
                          selected: feedState.mode == FeedMode.following,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ref
                                .read(feedControllerProvider.notifier)
                                .setMode(FeedMode.following);
                          },
                        ),
                        SizedBox(width: w * 0.008),
                        _TopTabChip(
                          label: 'استكشاف',
                          selected: feedState.mode == FeedMode.forYou,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ref
                                .read(feedControllerProvider.notifier)
                                .setMode(FeedMode.forYou);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: w * 0.04),

                  // messages icon + unread badge
                  InkWell(
                    onTap: () async {
                      final allowed = await requireLogin(context);
                      if (!allowed) return;
                      if (!mounted) return;
                      context.pushNamed('messages');
                    },
                    borderRadius: BorderRadius.circular(h * 0.014),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: EdgeInsets.all(h * 0.008),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(h * 0.014),
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: h * 0.026,
                          ),
                        ),
                        if (_unreadCountMock > 0)
                          Positioned(
                            top: -h * 0.006,
                            right: -w * 0.01,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.018,
                                vertical: h * 0.0035,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.orange,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  width: h * 0.0012,
                                ),
                              ),
                              child: Text(
                                _unreadCountMock > 99
                                    ? '99+'
                                    : '$_unreadCountMock',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ✅ Loading indicator صغير (ما بقطع الريلز)
            if (feedState.isLoading && reels.isNotEmpty)
              Positioned(
                top: paddingTop + h * 0.07,
                right: w * 0.045,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.028,
                    vertical: h * 0.008,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(h * 0.018),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: h * 0.018,
                        width: h * 0.018,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: w * 0.02),
                      Text(
                        'تحديث…',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

class _FollowChip extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  const _FollowChip({required this.isFollowing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final h = Responsive.height(context);
    final w = Responsive.width(context);

    final bg = isFollowing
        ? Colors.white.withValues(alpha: 0.16)
        : AppColors.teal.withValues(alpha: 0.92);

    final border = isFollowing
        ? Colors.white.withValues(alpha: 0.28)
        : Colors.transparent;

    final label = isFollowing ? 'متابَع' : 'متابعة';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(h * 0.018),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.035,
          vertical: h * 0.0065,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(h * 0.018),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: h * 0.012,
              offset: Offset(0, h * 0.004),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFollowing ? Icons.check_rounded : Icons.add_rounded,
              size: h * 0.018,
              color: Colors.white,
            ),
            SizedBox(width: w * 0.012),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFollowingState extends StatelessWidget {
  final double paddingTop;

  const _EmptyFollowingState({required this.paddingTop});

  @override
  Widget build(BuildContext context) {
    final h = Responsive.height(context);
    final w = Responsive.width(context);
    final theme = Theme.of(context);

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        top: paddingTop + h * 0.12,
        left: w * 0.10,
        right: w * 0.10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.storefront_outlined,
            color: Colors.white.withValues(alpha: 0.85),
            size: h * 0.08,
          ),
          SizedBox(height: h * 0.018),
          Text(
            'لسّه ما بتتابع أي متجر',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: h * 0.008),
          Text(
            'تابع متاجر بتعجبك من استكشاف، وبترجع بتلاقي كل جديد هون.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmptyExploreState extends StatelessWidget {
  final double paddingTop;

  const _EmptyExploreState({required this.paddingTop});

  @override
  Widget build(BuildContext context) {
    final h = Responsive.height(context);
    final w = Responsive.width(context);
    final theme = Theme.of(context);

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        top: paddingTop + h * 0.12,
        left: w * 0.10,
        right: w * 0.10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            color: Colors.white.withValues(alpha: 0.85),
            size: h * 0.08,
          ),
          SizedBox(height: h * 0.018),
          Text(
            'ما في ريلز حالياً',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: h * 0.008),
          Text(
            'قريباً رح تبلّش تشوف عروض حسب اهتماماتك.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TopTabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TopTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final h = Responsive.height(context);
    final w = Responsive.width(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.055,
          vertical: h * 0.006,
        ),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(h * 0.014),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Future<void> Function() onTap;
  final String label;
  final Color activeColor;

  const _CircleIconButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.label,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final h = Responsive.height(context);

    return Column(
      children: [
        InkResponse(
          onTap: () async => onTap(),
          radius: h * 0.04,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: EdgeInsets.all(h * 0.012),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.55),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              transitionBuilder: (child, anim) {
                return ScaleTransition(scale: anim, child: child);
              },
              child: Icon(
                icon,
                key: ValueKey(icon.codePoint),
                color: isActive ? activeColor : Colors.white,
                size: h * 0.026,
              ),
            ),
          ),
        ),
        SizedBox(height: h * 0.004),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

class _ShareAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ShareAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final h = Responsive.height(context);
    final w = Responsive.width(context);

    final radius = h * 0.02;

    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.04,
          vertical: h * 0.014,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(
            theme.brightness == Brightness.light ? 0.55 : 0.16,
          ),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: cs.outline.withOpacity(
              theme.brightness == Brightness.light ? 0.18 : 0.28,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: cs.secondary, size: w * 0.06),
            SizedBox(width: w * 0.02),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
