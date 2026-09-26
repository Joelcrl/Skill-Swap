import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeModeKey = 'theme_mode';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  ref.keepAlive();
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    ref.keepAlive();
    final prefs = ref.read(sharedPreferencesProvider);
    return _decode(prefs.getString(_kThemeModeKey));
  }

  Future<void> set(ThemeMode mode) async {
    // Defer the state change to AFTER the current frame so any in-progress
    // hit-test / ink-splash from the tap that triggered this finishes — and
    // gets fully painted — before the whole MaterialApp rebuilds with the
    // new theme. Switching theme inside an InkWell tap handler otherwise
    // trips a "render box never laid out" assertion in mouse_tracker.dart.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state != mode) state = mode;
    });
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_kThemeModeKey, _encode(mode));
  }

  static ThemeMode _decode(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String _encode(ThemeMode m) => switch (m) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
