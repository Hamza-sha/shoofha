// lib/core/localization/app_localizations.dart
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const supportedLocales = [Locale('ar'), Locale('en')];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Shoofha',
      'general_retry': 'Retry',
      'general_error': 'Something went wrong',
      'loading_settings': 'Loading your experience...',
    },
    'ar': {
      'app_name': 'شوفها',
      'general_retry': 'إعادة المحاولة',
      'general_error': 'حدث خطأ غير متوقع',
      'loading_settings': 'جاري تهيئة تجربتك...',
    },
  };

  String tr(String key) {
    final langCode = locale.languageCode;
    return _localizedValues[langCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (l) => l.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
