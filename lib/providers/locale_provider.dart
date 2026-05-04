// lib/providers/locale_provider.dart
// Manages the app UI language independently from the device language setting.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_localizations.dart';

class LocaleProvider extends ChangeNotifier {
  String _locale = AppLocalizations.defaultLocale;
  String get locale => _locale;

  AppLocalizations get l10n => AppLocalizations(_locale);

  LocaleProvider() {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_locale');
    if (saved != null && ['ar', 'en', 'fr', 'tr', 'de'].contains(saved)) {
      _locale = saved;
      notifyListeners();
    }
  }

  Future<void> setLocale(String locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', locale);
  }

  // Text direction based on current locale
  bool get isRtl => _locale == 'ar';
}
