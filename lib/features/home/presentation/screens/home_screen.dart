import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/core/responsive/responsive.dart';
import 'package:shoofha/core/theme/app_colors.dart';
import 'package:shoofha/core/auth/guest_guard.dart';
import 'package:shoofha/features/social/application/reactions_controller.dart';

enum HomeFeedTab { following, explore }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();
  HomeFeedTab _currentTab = HomeFeedTab.explore;

  final List<_Reel> _dummyReels = [
    _Reel(
      storeId: 'coffee-mood',
      storeName: 'Coffee Mood',
      storeInitial: 'C',
      category: 'كافيه',
      distanceKm: 1.2,
      likes: 12500,
      saves: 3200,
      title: 'خصم 30٪ على كل مشروبات القهوة المختصّة اليوم فقط!',
      subtitle: 'جرّب لاتيه البندق أو الكابتشينو المثلّج بسعر أقل.',
      priceLabel: 'متوسط السعر من 1.5 دينار',
      cta: 'شوف قائمة المشروبات',
      color: const Color(0xFF6A1B9A),
    ),
    _Reel(
      storeId: 'fit-zone',
      storeName: 'Fit Zone Gym',
      storeInitial: 'F',
      category: 'نادي رياضي',
      distanceKm: 2.8,
      likes: 9800,
      saves: 4100,
      title: 'اشترك اليوم وخذ أول أسبوع مجاناً!',
      subtitle: 'أجهزة جديدة + حصص كروس فت وزومبا على مدار الأسبوع.',
      priceLabel: 'الباقات تبدأ من 25 دينار بالشهر',
      cta: 'شوف الباقات والعروض',
      color: const Color(0xFF1B5E20),
    ),
    _Reel(
      storeId: 'pizza-house',
      storeName: 'Pizza House',
      storeInitial: 'P',
      category: 'مطعم بيتزا',
      distanceKm: 0.9,
      likes: 15700,
      saves: 5200,
      title: 'عرض العائلة: 2 بيتزا كبيرة + مشروبات',
      subtitle: 'اختر من منيو البيتزا الخاصة ووفّر لحد 35٪.',
      priceLabel: 'العرض بـ 14.99 دينار فقط',
      cta: 'اطلب العرض الآن',
      color: const Color(0xFFD32F2F),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatLikes(int value) {
    if (value >= 1000) {
      final double k = value / 1000;
      return '${k.toStringAsFixed(k % 1 == 0 ? 0 : 1)}K';
    }
    return value.toString();
  }

  bool _isLiked(_Reel reel) => ref
      .watch(reactionsControllerProvider)
      .likedStoreIds
      .contains(reel.storeId);

  bool _isSaved(_Reel reel) => ref
      .watch(reactionsControllerProvider)
      .savedStoreIds
      .contains(reel.storeId);

  Future<void> _toggleLike(_Reel reel, BuildContext context) async {
    final allowed = await requireLogin(context);
    if (!allowed) return;
    if (!mounted) return;

    HapticFeedback.lightImpact();
    ref.read(reactionsControllerProvider.notifier).toggleLike(reel.storeId);
  }

  Future<void> _toggleSave(_Reel reel, BuildContext context) async {
    final allowed = await requireLogin(context);
    if (!allowed) return;
    if (!mounted) return;

    HapticFeedback.lightImpact();
    ref.read(reactionsControllerProvider.notifier).toggleSave(reel.storeId);
  }

  void _openStore(_Reel reel, BuildContext context) {
    context.pushNamed('store', pathParameters: {'id': reel.storeId});
  }

  @override
  Widget build(BuildContext context) {
    final h = Responsive.height(context);
    final w = Responsive.width(context);
    final theme = Theme.of(context);
    final paddingTop = MediaQuery.of(context).padding.top;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // Reels
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _dummyReels.length,
              itemBuilder: (context, index) {
                final reel = _dummyReels[index];
                final isLiked = _isLiked(reel);
                final isSaved = _isSaved(reel);

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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          reel.storeName,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                          textAlign: TextAlign.right,
                                        ),
                                        SizedBox(height: h * 0.004),
                                        Text(
                                          reel.category,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: Colors.white.withValues(
                                                  alpha: 0.80,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: w * 0.03),
                                    CircleAvatar(
                                      radius: h * 0.022,
                                      backgroundColor: Colors.white,
                                      child: Text(
                                        reel.storeInitial,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
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
                                        color: Colors.black.withValues(
                                          alpha: 0.55,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          h * 0.016,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${reel.distanceKm.toStringAsFixed(1)} كم',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(color: Colors.white),
                                          ),
                                          SizedBox(width: w * 0.008),
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: w * 0.02),
                                    Flexible(
                                      child: Text(
                                        reel.priceLabel,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: Colors.white),
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
                                    padding: EdgeInsets.symmetric(
                                      vertical: h * 0.015,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.centerRight,
                                        end: Alignment.centerLeft,
                                        colors: [
                                          AppColors.teal,
                                          AppColors.purple,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        h * 0.02,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        reel.cta,
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
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
                              icon: isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              isActive: isLiked,
                              onTap: () => _toggleLike(reel, context),
                              label: _formatLikes(reel.likes),
                              activeColor: Colors.redAccent,
                            ),
                            SizedBox(height: h * 0.018),
                            _CircleIconButton(
                              icon: isSaved
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
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
                          selected: _currentTab == HomeFeedTab.following,
                          onTap: () {
                            setState(() => _currentTab = HomeFeedTab.following);
                          },
                        ),
                        SizedBox(width: w * 0.008),
                        _TopTabChip(
                          label: 'استكشاف',
                          selected: _currentTab == HomeFeedTab.explore,
                          onTap: () {
                            setState(() => _currentTab = HomeFeedTab.explore);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: w * 0.04),
                  InkWell(
                    onTap: () async {
                      final allowed = await requireLogin(context);
                      if (!allowed) return;
                      if (!mounted) return;

                      context.pushNamed('messages');
                    },
                    borderRadius: BorderRadius.circular(h * 0.014),
                    child: Container(
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

class _Reel {
  final String storeId;
  final String storeName;
  final String storeInitial;
  final String category;
  final double distanceKm;
  final int likes;
  final int saves;
  final String title;
  final String subtitle;
  final String priceLabel;
  final String cta;
  final Color color;

  _Reel({
    required this.storeId,
    required this.storeName,
    required this.storeInitial,
    required this.category,
    required this.distanceKm,
    required this.likes,
    required this.saves,
    required this.title,
    required this.subtitle,
    required this.priceLabel,
    required this.cta,
    required this.color,
  });
}
