part of 'settings_cubit.dart';

enum AppThemeMode {
  system,
  light,
  dark;

  String get label {
    switch (this) {
      case AppThemeMode.system:
        return 'Sistema';
      case AppThemeMode.light:
        return 'Chiaro';
      case AppThemeMode.dark:
        return 'Scuro';
    }
  }
}

class SettingsState extends Equatable {
  const SettingsState({this.themeMode = AppThemeMode.system});

  final AppThemeMode themeMode;

  SettingsState copyWith({AppThemeMode? themeMode}) {
    return SettingsState(themeMode: themeMode ?? this.themeMode);
  }

  @override
  List<Object> get props => [themeMode];
}
