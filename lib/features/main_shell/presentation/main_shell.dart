import 'package:flutter/material.dart';

import 'package:shoofha/features/home/presentation/screens/home_screen.dart';
import 'package:shoofha/features/explore/presentation/screens/explore_screen.dart';
import 'package:shoofha/features/offers/presentation/screens/top_offers_screen.dart';
import 'package:shoofha/features/cart/presentation/screens/cart_screen.dart';
import 'package:shoofha/features/profile/presentation/screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

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
  }

  void _onDestinationSelected(int value) {
    if (_index == value) return;
    setState(() {
      _index = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isWide = size.width >= 900; // ????? / ???

    final destinations = const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: '????????',
      ),
      NavigationDestination(
        icon: Icon(Icons.search),
        selectedIcon: Icon(Icons.search),
        label: '???????',
      ),
      NavigationDestination(
        icon: Icon(Icons.local_offer_outlined),
        selectedIcon: Icon(Icons.local_offer),
        label: '??????',
      ),
      NavigationDestination(
        icon: Icon(Icons.shopping_cart_outlined),
        selectedIcon: Icon(Icons.shopping_cart),
        label: '?????',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: '??????',
      ),
    ];

    final body = PageStorage(
      bucket: _bucket,
      child: IndexedStack(index: _index, children: _screens),
    );

    // ?? ???? ?????: NavigationRail ??? ??????
    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRailTheme(
              data: NavigationRailThemeData(
                backgroundColor: theme.scaffoldBackgroundColor,
                selectedIconTheme: IconThemeData(
                  color: colorScheme.primary,
                  size: size.height * 0.032,
                ),
                unselectedIconTheme: IconThemeData(
                  color: theme.iconTheme.color?.withOpacity(0.7),
                  size: size.height * 0.028,
                ),
                selectedLabelTextStyle: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
                unselectedLabelTextStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              child: NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: _onDestinationSelected,
                labelType: NavigationRailLabelType.all,
                extended: size.width >= 1200,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: Text('????????'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.search),
                    selectedIcon: Icon(Icons.search),
                    label: Text('???????'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.local_offer_outlined),
                    selectedIcon: Icon(Icons.local_offer),
                    label: Text('??????'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.shopping_cart_outlined),
                    selectedIcon: Icon(Icons.shopping_cart),
                    label: Text('?????'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: Text('??????'),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    // ?? ??????: NavigationBar
    final navHeight = size.height * 0.085;

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
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _onDestinationSelected,
          destinations: destinations,
        ),
      ),
    );
  }
}
