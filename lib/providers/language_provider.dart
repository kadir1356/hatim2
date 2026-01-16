import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../l10n/app_localizations.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  static const String _localeBoxName = 'app_locale';
  static const String _localeKey = 'current_locale';

  LanguageProvider() {
    _loadLocale();
  }

  Locale get locale => _locale;
  bool get isRTL => _locale.languageCode == 'ar';

  Future<void> _loadLocale() async {
    try {
      final box = await Hive.openBox(_localeBoxName);
      final savedLocale = box.get(_localeKey, defaultValue: 'en');
      _locale = Locale(savedLocale);
      notifyListeners();
    } catch (e) {
      print('Error loading locale: $e');
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!AppLocalizations.delegate.isSupported(locale)) {
      return;
    }
    
    _locale = locale;
    notifyListeners();
    
    try {
      final box = await Hive.openBox(_localeBoxName);
      await box.put(_localeKey, locale.languageCode);
    } catch (e) {
      print('Error saving locale: $e');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    await setLocale(Locale(languageCode));
  }
}
