import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  static const String _localeKey = 'locale';

  AppState({Locale? initialLocale}) {
    _locale = initialLocale ?? const Locale('tr');
  }

  bool _isBusy = false;
  bool get isbusy => _isBusy;
  set loading(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  int _pageIndex = 0;
  int get pageIndex => _pageIndex;

  /// Last bottom bar tab index before switching to Profile (0=Feed, 1=Search, 2=Notifications). Used when "back" from Profile tab.
  int _lastTabBeforeProfile = 0;
  int get lastTabBeforeProfile => _lastTabBeforeProfile;

  set setpageIndex(int index) {
    if (index == 3) {
      _lastTabBeforeProfile = _pageIndex;
    } else {
      _lastTabBeforeProfile = index;
    }
    _pageIndex = index;
    if (index == 0) _feedBottomBarVisible = true;
    notifyListeners();
  }

  /// Feed sekmesinde bottom bar görünürlüğü (NestedScrollView iç scroll'dan gelen yöne göre).
  bool _feedBottomBarVisible = true;
  bool get feedBottomBarVisible => _feedBottomBarVisible;
  set setFeedBottomBarVisible(bool value) {
    if (_feedBottomBarVisible == value) return;
    _feedBottomBarVisible = value;
    notifyListeners();
  }

  Locale? _locale;

  /// Never null at runtime: app language is saved preference or default Turkish.
  Locale get locale => _locale ?? const Locale('tr');

  /// Loads saved locale from SharedPreferences. Call once after app start.
  /// Does not overwrite with invalid value; defaults to Turkish and optionally writes back.
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    final Locale newLocale =
        (code != null && ['tr', 'en', 'de'].contains(code)) ? Locale(code) : const Locale('tr');
    if (newLocale.languageCode != (_locale ?? const Locale('tr')).languageCode) {
      _locale = newLocale;
      if (code == null || !['tr', 'en', 'de'].contains(code)) {
        await prefs.setString(_localeKey, 'tr');
      }
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
