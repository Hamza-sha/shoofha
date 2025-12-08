import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/core/responsive/responsive.dart';
import 'package:shoofha/core/auth/guest_guard.dart';
import 'package:shoofha/app/theme/app_theme.dart';

enum HomeFeedTab { explore, following }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeFeedTab _currentTab = HomeFeedTab.explore;

  @override
  Widget build(BuildContext context) {
    // ?????? ???? ????? ??? ????? (explore/following)
    final reels = _dummyReels;

    return Scaffold(
      // ??????? ????? ?? ??????? ??? ?? ???? ????? ???
      body: Stack(
        children: [
          // ?????? (????????) - ???? ????? ???
          PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: reels.length,
            itemBuilder: (context, index) {
              final reel = reels[index];
              return _ReelPage(reel: reel);
            },
          ),

          // ???? ???? ???: Shoofha + Explore / Following + ?? ???????
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.width(context) * 0.04,
                vertical: Responsive.height(context) * 0.015,
              ),
              child: _HomeTopBar(
                currentTab: _currentTab,
                onTabChanged: (tab) {
                  setState(() {
                    _currentTab = tab;
                    // ?? ??? ???? ?????? ??? ?????? ??? ?????? ???????
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ???? ??? ????? (????? ??????? + ????? ??? ?????? ??????)
class _ReelPage extends StatelessWidget {
  final _Reel reel;

  const _ReelPage({required this.reel});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);

    return Stack(
      children: [
        // ????? ????? (Gradient ??? ??? ??? ??????)
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                reel.backgroundColor.withOpacity(0.9),
                reel.backgroundColor.withOpacity(0.6),
              ],
            ),
          ),
        ),

        // ????? ????/???? ???? ?????? ???? ??????
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.40),
                Colors.black.withOpacity(0.10),
                Colors.black.withOpacity(0.65),
              ],
            ),
          ),
        ),

        // ??????? (?? ??? ?????? ???)
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.04,
              vertical: h * 0.015,
            ),
            child: Column(
              children: [
                // ????? ????? ???? ?????? ??????
                SizedBox(height: h * 0.08),

                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: _StoreInfoSection(reel: reel)),
                      _ActionsColumn(reel: reel),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ???? ???? ?????? (????): ???? + ????? Explore / Following + ????? 
class _HomeTopBar extends StatelessWidget {
  final HomeFeedTab currentTab;
  final ValueChanged<HomeFeedTab> onTabChanged;

  const _HomeTopBar({required this.currentTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        Text(
          'Shoofha',
          style: TextStyle(
            fontSize: w * 0.06,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),

        Row(
          children: [
            // ????? Explore / Following
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.02,
                vertical: w * 0.008,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  _TopTab(
                    label: 'Explore',
                    isActive: currentTab == HomeFeedTab.explore,
                    onTap: () => onTabChanged(HomeFeedTab.explore),
                  ),
                  const SizedBox(width: 8),
                  _TopTab(
                    label: 'Following',
                    isActive: currentTab == HomeFeedTab.following,
                    onTap: () => onTabChanged(HomeFeedTab.following),
                  ),
                ],
              ),
            ),
            SizedBox(width: w * 0.02),

            // ?? ??????? ???? ???? ??????? (???? ???)
            InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                context.pushNamed('messages');
              },
              child: Padding(
                padding: EdgeInsets.all(w * 0.012),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TopTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TopTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.02,
          vertical: w * 0.005,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: w * 0.033,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}

/// ????? ?????? ??????: ??????? ?????? + ?????? + CTA
class _StoreInfoSection extends StatelessWidget {
  final _Reel reel;

  const _StoreInfoSection({required this.reel});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final theme = Theme.of(context);
    final shoofhaTheme = theme.extension<ShoofhaTheme>();

    return Padding(
      padding: EdgeInsets.only(bottom: h * 0.02),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ??? ?????? + ????????
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: w * 0.045,
                backgroundColor: Colors.white.withOpacity(0.9),
                child: Text(
                  reel.storeName.characters.first,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: w * 0.045,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: w * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reel.storeName,
                    style: TextStyle(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    reel.category,
                    style: TextStyle(
                      fontSize: w * 0.032,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: h * 0.015),

          // ????? ?????
          Text(
            reel.title,
            style: TextStyle(
              fontSize: w * 0.04,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: h * 0.008),

          // ????? + ???????
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.025,
                  vertical: w * 0.01,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  reel.priceLabel,
                  style: TextStyle(
                    fontSize: w * 0.035,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: w * 0.02),
              Icon(
                Icons.location_on_outlined,
                size: w * 0.045,
                color: Colors.white.withOpacity(0.9),
              ),
              Text(
                '${reel.distanceKm.toStringAsFixed(1)} ??',
                style: TextStyle(
                  fontSize: w * 0.033,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.014),

          // CTA Buttons (????? ?????? + ????? ?? ???? ??? ?????? ?????)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: h * 0.052,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient:
                          shoofhaTheme?.primaryButtonGradient ??
                          const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.navy, AppColors.purple],
                          ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () {
                          context.pushNamed(
                            'store',
                            pathParameters: {'id': reel.storeId},
                          );
                        },
                        child: Center(
                          child: Text(
                            reel.cta,
                            style: TextStyle(
                              fontSize: w * 0.038,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: w * 0.02),
              SizedBox(height: h * 0.048, width: h * 0.048),
            ],
          ),
        ],
      ),
    );
  }
}

/// ???? ????? ??????? (????? ???? ??????)
class _ActionsColumn extends StatelessWidget {
  final _Reel reel;

  const _ActionsColumn({required this.reel});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);

    return Padding(
      padding: EdgeInsets.only(bottom: h * 0.03, left: w * 0.02),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          _ActionIcon(icon: Icons.favorite_border, label: '12.5K'),
          SizedBox(height: 12),
          _ActionIcon(icon: Icons.bookmark_border, label: '???'),
          SizedBox(height: 12),
          _ActionIcon(icon: Icons.share_outlined, label: '??????'),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);

    return Column(
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () async {
            final ok = await requireLogin(context);
            if (!ok) return;
            // TODO: ????? ???? / ??? / ?????? ?????? ??? ???? backend
          },
          child: Container(
            padding: EdgeInsets.all(w * 0.018),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: w * 0.06, color: Colors.white),
          ),
        ),
        SizedBox(height: w * 0.01),
        Text(
          label,
          style: TextStyle(fontSize: w * 0.03, color: Colors.white),
        ),
      ],
    );
  }
}

/// ????? ?????? ??? Reel
class _Reel {
  final String storeId;
  final String storeName;
  final String title;
  final String category;
  final double distanceKm;
  final String priceLabel;
  final String cta;
  final Color backgroundColor;

  _Reel({
    required this.storeId,
    required this.storeName,
    required this.title,
    required this.category,
    required this.distanceKm,
    required this.priceLabel,
    required this.cta,
    required this.backgroundColor,
  });
}

/// ?????? ??????? (Dummy)
final List<_Reel> _dummyReels = [
  _Reel(
    storeId: 'coffee-mood',
    storeName: 'Coffee Mood',
    title: '??? 30% ??? ???? ????????? ??????? ????? ???! ??',
    category: '?????',
    distanceKm: 1.2,
    priceLabel: '??????? ?? 1.5 ?????',
    cta: '????? ??????',
    backgroundColor: const Color(0xFF3E2723),
  ),
  _Reel(
    storeId: 'fit-zone',
    storeName: 'FitZone Gym',
    title: '????? ????? ??? ?????? ?????? ??',
    category: '???? ?????',
    distanceKm: 3.8,
    priceLabel: '99 ????? / 3 ????',
    cta: '???? ???????',
    backgroundColor: const Color(0xFF1B5E20),
  ),
  _Reel(
    storeId: 'tech-corner',
    storeName: 'Tech Corner',
    title: '???? ???? ??? ???????? ??????? ???? ??',
    category: '??????????',
    distanceKm: 5.4,
    priceLabel: '?????? ??? 40%',
    cta: '??? ??????',
    backgroundColor: const Color(0xFF0D47A1),
  ),
];
