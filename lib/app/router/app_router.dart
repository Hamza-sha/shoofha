import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/features/auth/presentation/screens/splash_screen.dart';
import 'package:shoofha/features/auth/presentation/screens/welcome_screen.dart';
import 'package:shoofha/features/auth/presentation/screens/login_screen.dart';
import 'package:shoofha/features/auth/presentation/screens/signup_screen.dart';
import 'package:shoofha/features/auth/presentation/screens/otp_screen.dart';
import 'package:shoofha/features/auth/presentation/screens/choose_interests_screen.dart';

import 'package:shoofha/features/commerce/presentation/screens/my_orders_screen.dart';
import 'package:shoofha/features/commerce/presentation/screens/checkout_screen.dart';
import 'package:shoofha/features/commerce/presentation/screens/order_success_screen.dart';

import 'package:shoofha/features/main_shell/presentation/main_shell.dart';
import 'package:shoofha/features/messaging/presentation/screens/notifications_screen.dart';
import 'package:shoofha/features/settings/presentation/screens/settings_screen.dart';
import 'package:shoofha/features/social/presentation/screens/favorites_screen.dart';

import 'package:shoofha/features/store/presentation/screens/store_profile_screen.dart';
import 'package:shoofha/features/store/presentation/screens/product_details_screen.dart';

import 'package:shoofha/features/messages/presentation/screens/messages_inbox_screen.dart';
import 'package:shoofha/features/messages/presentation/screens/chat_screen.dart';

import 'package:shoofha/features/auth/application/auth_notifier.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  refreshListenable: authNotifier,

  redirect: (context, state) {
    final isLoggedIn = authNotifier.isLoggedIn;
    final hasCompletedInterests = authNotifier.hasCompletedInterests;
    final location = state.matchedLocation;

    const publicRoutes = <String>{
      '/splash',
      '/welcome',
      '/login',
      '/signup',
      '/otp',
    };

    const authFlowRoutes = <String>{
      '/welcome',
      '/login',
      '/signup',
      '/otp',
      '/choose-interests',
    };

    if (!isLoggedIn) {
      if (publicRoutes.contains(location)) return null;
      return '/welcome';
    }

    if (isLoggedIn && !hasCompletedInterests) {
      if (location == '/otp' || location == '/choose-interests') return null;
      return '/otp';
    }

    if (isLoggedIn &&
        hasCompletedInterests &&
        authFlowRoutes.contains(location)) {
      return '/app';
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/otp',
      name: 'otp',
      builder: (context, state) => const OtpScreen(),
    ),
    GoRoute(
      path: '/choose-interests',
      name: 'choose-interests',
      builder: (context, state) => const ChooseInterestsScreen(),
    ),

    GoRoute(
      path: '/app',
      name: 'app',
      builder: (context, state) => const MainShell(),
    ),

    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),

    GoRoute(
      path: '/store/:id',
      name: 'store',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'unknown';
        return StoreProfileScreen(storeId: id);
      },
    ),

    GoRoute(
      path: '/product/:id',
      name: 'product',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'unknown';
        return ProductDetailsScreen(productId: id);
      },
    ),

    GoRoute(
      path: '/messages',
      name: 'messages',
      builder: (context, state) => const MessagesInboxScreen(),
    ),
    GoRoute(
      path: '/chat/:id',
      name: 'chat',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'unknown';
        return ChatScreen(conversationId: id);
      },
    ),

    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    GoRoute(
      path: '/orders',
      name: 'orders',
      builder: (context, state) => const OrdersScreen(),
    ),

    GoRoute(
      path: '/checkout',
      name: 'checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),

    // ✅ نجاح الطلب (لازم extra من نوع OrderSuccessArgs)
    GoRoute(
      path: '/order-success',
      name: 'order-success',
      builder: (context, state) {
        final extra = state.extra;

        final args = extra is OrderSuccessArgs
            ? extra
            : const OrderSuccessArgs(orderId: 'SH-UNKNOWN', total: 0);

        return OrderSuccessScreen(args: args);
      },
    ),

    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
  ],
);
