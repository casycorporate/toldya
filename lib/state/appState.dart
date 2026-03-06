import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  static const String _localeKey = 'locale';

  bool _isBusy = false;
  bool get isbusy => _isBusy;
  set loading(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  int _pageIndex = 0;
  int get pageIndex => _pageIndex;
  set setpageIndex(int index) {
    _pageIndex = index;
    notifyListeners();
  }

  Locale? _locale;
  Locale? get locale => _locale;

  /// Loads saved locale from SharedPreferences. Call once after app start.
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code != null && ['tr', 'en', 'de'].contains(code)) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  /// Sets app locale and persists to SharedPreferences.
  Future<void> setLocale(Locale value) async {
    _locale = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, value.languageCode);
    notifyListeners();
  }
}
