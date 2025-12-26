import 'package:flutter/material.dart';

import 'package:shoofha/features/home/presentation/screens/home_screen.dart';
import 'package:shoofha/features/explore/presentation/screens/explore_screen.dart';
import 'package:shoofha/features/offers/presentation/screens/top_offers_screen.dart';
import 'package:shoofha/features/cart/presentation/screens/cart_screen.dart';
import 'package:shoofha/features/profile/presentation/screens/profile_screen.dart';

/// ✅ Controller بسيط لTabs داخل MainShell بدون Router
/// تقدر تستدعيه من أي مكان:
/// MainShellTabs.setIndex(3); ثم context.go('/app');
class MainShellTabs {
  static final ValueNotifier<int> index = ValueNotifier<int>(0);

  static void setIndex(int value) {
    if (value < 0) return;
    if (value > 4) return;
    if (index.value == value) return;
    index.value = value;
  }

  static int get current => index.value;

  // اختصارات لطيفة
  static void goHome() => setIndex(0);
  static void goExplore() => setIndex(1);
  static void goOffers() => setIndex(2);
  static void goCart() => setIndex(3);
  static void goProfile() => setIndex(4);
}

class MainShell extends StatefulWidget {
  /// ✅ اختياري: لو بدك تفتح MainShell على Tab معيّن أول ما يدخل
  final int? initialIndex;

  const MainShell({super.key, this.initialIndex});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final List<Widget> _screens;
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();

    _screens = const [
      HomeScreen(),
      ExploreScreen(),
      TopOffersScreen(),
      CartScreen(),
      ProfileScreen(),
    ];

    // ✅ لو حاب تفتح على تب معيّن
    final init = widget.initialIndex;
    if (init != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        MainShellTabs.setIndex(init);
      });
    }
  }

  void _onDestinationSelected(int value) {
    MainShellTabs.setIndex(value);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isWide = size.width >= 900;

    // ✅ Labels واضحة بدل ???؟
    const labels = <String>['Home', 'Explore', 'Offers', 'Cart', 'Profile'];

    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: labels[0],
      ),
      NavigationDestination(
        icon: const Icon(Icons.search),
        selectedIcon: const Icon(Icons.search),
        label: labels[1],
      ),
      NavigationDestination(
        icon: const Icon(Icons.local_offer_outlined),
        selectedIcon: const Icon(Icons.local_offer),
        label: labels[2],
      ),
      NavigationDestination(
        icon: const Icon(Icons.shopping_cart_outlined),
        selectedIcon: const Icon(Icons.shopping_cart),
        label: labels[3],
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person),
        label: labels[4],
      ),
    ];

    // ✅ Body صار يعتمد على ValueNotifier بدل _index المحلي
    final body = ValueListenableBuilder<int>(
      valueListenable: MainShellTabs.index,
      builder: (context, currentIndex, _) {
        return PageStorage(
          bucket: _bucket,
          child: IndexedStack(index: currentIndex, children: _screens),
        );
      },
    );

    // ✅ Wide: NavigationRail
    if (isWide) {
      return ValueListenableBuilder<int>(
        valueListenable: MainShellTabs.index,
        builder: (context, currentIndex, _) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRailTheme(
                  data: NavigationRailThemeData(
                    backgroundColor: theme.scaffoldBackgroundColor,
                    selectedIconTheme: IconThemeData(
                      color: colorScheme.secondary, // active = Teal
                      size: size.height * 0.032,
                    ),
                    unselectedIconTheme: IconThemeData(
                      color: theme.iconTheme.color?.withOpacity(0.7),
                      size: size.height * 0.028,
                    ),
                    selectedLabelTextStyle: theme.textTheme.bodyMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.secondary,
                        ),
                    unselectedLabelTextStyle: theme.textTheme.bodyMedium
                        ?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.7,
                          ),
                        ),
                  ),
                  child: NavigationRail(
                    selectedIndex: currentIndex,
                    onDestinationSelected: _onDestinationSelected,
                    labelType: NavigationRailLabelType.all,
                    extended: size.width >= 1200,
                    destinations: [
                      NavigationRailDestination(
                        icon: const Icon(Icons.home_outlined),
                        selectedIcon: const Icon(Icons.home),
                        label: Text(labels[0]),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.search),
                        selectedIcon: const Icon(Icons.search),
                        label: Text(labels[1]),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.local_offer_outlined),
                        selectedIcon: const Icon(Icons.local_offer),
                        label: Text(labels[2]),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        selectedIcon: const Icon(Icons.shopping_cart),
                        label: Text(labels[3]),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.person_outline),
                        selectedIcon: const Icon(Icons.person),
                        label: Text(labels[4]),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        },
      );
    }

    // ✅ Mobile: NavigationBar (نفس تصميمك + polishing)
    final navHeight = size.height * 0.085;

    return ValueListenableBuilder<int>(
      valueListenable: MainShellTabs.index,
      builder: (context, currentIndex, _) {
        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: navHeight,
              backgroundColor: theme.scaffoldBackgroundColor,
              indicatorColor: colorScheme.secondary.withOpacity(0.16),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final isSelected = states.contains(WidgetState.selected);
                return theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final isSelected = states.contains(WidgetState.selected);
                return IconThemeData(
                  color: isSelected
                      ? colorScheme.secondary
                      : theme.iconTheme.color?.withOpacity(0.75),
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: destinations,
            ),
          ),
        );
      },
    );
  }
}
