import 'package:web/web.dart' as web;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _key = 'theme_mode';

  static const _lightColor = '#EEEFF6';
  static const _darkColor = '#161929';

  ThemeCubit() : super(ThemeMode.dark) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == 'light') {
      emit(ThemeMode.light);
      _updateThemeColor(ThemeMode.light);
    } else if (value == 'system') {
      emit(ThemeMode.system);
    } else {
      emit(ThemeMode.dark);
      _updateThemeColor(ThemeMode.dark);
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    _updateThemeColor(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setTheme(next);
  }

  void _updateThemeColor(ThemeMode mode) {
    if (!kIsWeb) return;
    final color = mode == ThemeMode.light ? _lightColor : _darkColor;
    try {
      final metas = web.document.querySelectorAll('meta[name="theme-color"]');
      for (var i = 0; i < metas.length; i++) {
        (metas.item(i) as web.Element?)?.setAttribute('content', color);
      }
    } catch (_) {}
  }
}
