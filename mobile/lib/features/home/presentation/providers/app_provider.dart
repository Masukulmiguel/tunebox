import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/cache_service.dart';

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService.instance;
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;

  ThemeModeNotifier(this._ref) : super(ThemeMode.dark) {
    _loadTheme();
  }

  void _loadTheme() {
    final isDark = _ref.read(cacheServiceProvider).isDarkMode;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _ref.read(cacheServiceProvider).setSetting('dark_mode', state == ThemeMode.dark);
  }
}

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
