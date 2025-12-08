import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;

  const SettingsState({required this.themeMode, required this.locale});

  SettingsState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsController extends AsyncNotifier<SettingsState> {
  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale_code';

  @override
  Future<SettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();

    final themeString = prefs.getString(_themeKey);
    final localeCode = prefs.getString(_localeKey);

    final themeMode = _stringToThemeMode(themeString);
    final locale = _stringToLocale(localeCode);

    return SettingsState(themeMode: themeMode, locale: locale);
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themeModeToString(mode));

    final current = state.asData?.value; // 👈 بدل valueOrNull
    if (current == null) return;

    state = AsyncData(current.copyWith(themeMode: mode));
  }

  Future<void> updateLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);

    final current = state.asData?.value; // 👈 بدل valueOrNull
    if (current == null) return;

    state = AsyncData(current.copyWith(locale: locale));
  }

  // Helpers

  ThemeMode _stringToThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Locale _stringToLocale(String? code) {
    switch (code) {
      case 'en':
        return const Locale('en');
      case 'ar':
      default:
        return const Locale('ar');
    }
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, SettingsState>(
      SettingsController.new,
    );
