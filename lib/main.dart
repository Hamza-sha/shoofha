// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:shoofha/app/router/app_router.dart';
import 'package:shoofha/app/theme/app_theme.dart';
import 'package:shoofha/core/localization/app_localizations.dart';
import 'package:shoofha/features/settings/application/settings_controller.dart';

// ✅ جديد: استرجاع حالة تسجيل الدخول والاهتمامات قبل تشغيل التطبيق
import 'package:shoofha/features/auth/application/auth_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ مهم: restore لحالة Auth قبل ما يشتغل router redirects
  await authNotifier.restore();

  runApp(const ProviderScope(child: ShoofhaApp()));
}

class ShoofhaApp extends ConsumerWidget {
  const ShoofhaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return settingsAsync.when(
      loading: () {
        // مرحلة تحميل الإعدادات من SharedPreferences
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Shoofha',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const _InitialLoadingScreen(),
        );
      },
      error: (error, stack) {
        // لو صار خطأ بتحميل الإعدادات
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Shoofha',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: _SettingsErrorScreen(error: error),
        );
      },
      data: (settings) {
        // الحالة الطبيعية بعد تحميل الإعدادات
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Shoofha',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: appRouter,
        );
      },
    );
  }
}

// شاشة بسيطة لمرحلة تحميل الإعدادات
class _InitialLoadingScreen extends StatelessWidget {
  const _InitialLoadingScreen();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(t.tr('loading_settings'), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// شاشة بسيطة في حال فشل تحميل الإعدادات
class _SettingsErrorScreen extends StatelessWidget {
  final Object error;

  const _SettingsErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.tr('general_error'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
