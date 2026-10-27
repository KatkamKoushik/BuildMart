import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/products/data/product_providers.dart'; // For sharedPreferencesProvider

// --- Theme Provider ---
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this.ref) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  final Ref ref;
  static const String _themeKey = 'app_theme_mode';

  void _loadThemeMode() {
    final prefs = ref.read(sharedPreferencesProvider);
    final themeStr = prefs.getString(_themeKey);
    if (themeStr == 'light') {
      state = ThemeMode.light;
    } else if (themeStr == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    state = mode;

    String themeStr = 'system';
    if (mode == ThemeMode.light) themeStr = 'light';
    if (mode == ThemeMode.dark) themeStr = 'dark';

    await prefs.setString(_themeKey, themeStr);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});

// --- Locale Provider ---
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier(this.ref) : super(null) {
    _loadLocale();
  }

  final Ref ref;
  static const String _localeKey = 'app_locale';

  void _loadLocale() {
    final prefs = ref.read(sharedPreferencesProvider);
    final localeStr = prefs.getString(_localeKey);
    if (localeStr != null) {
      state = Locale(localeStr);
    }
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    state = locale;
    await prefs.setString(_localeKey, locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier(ref);
});
