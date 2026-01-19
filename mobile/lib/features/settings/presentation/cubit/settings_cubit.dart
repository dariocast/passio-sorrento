import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences,
      super(const SettingsState()) {
    _loadSettings();
  }

  final SharedPreferences _sharedPreferences;
  static const _themeModeKey = 'theme_mode';

  void _loadSettings() {
    final themeModeIndex = _sharedPreferences.getInt(_themeModeKey);
    if (themeModeIndex != null &&
        themeModeIndex >= 0 &&
        themeModeIndex < AppThemeMode.values.length) {
      emit(state.copyWith(themeMode: AppThemeMode.values[themeModeIndex]));
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    await _sharedPreferences.setInt(_themeModeKey, mode.index);
    emit(state.copyWith(themeMode: mode));
  }

  /// Helper to convert AppThemeMode to Flutter's ThemeMode
  ThemeMode get themeMode {
    switch (state.themeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}
