import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/tracking_config.dart';

/// Service for persisting tracking configuration.
class ConfigService {
  static const _configKey = 'tracking_config';

  /// Save configuration to storage.
  Future<void> saveConfig(TrackingConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_configKey, jsonEncode(config.toJson()));
  }

  /// Load configuration from storage.
  /// Returns default config if none is saved.
  Future<TrackingConfig> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString(_configKey);

    if (configJson != null) {
      try {
        return TrackingConfig.fromJson(jsonDecode(configJson));
      } catch (e) {
        return TrackingConfig.defaultConfig;
      }
    }

    return TrackingConfig.defaultConfig;
  }

  /// Clear saved configuration.
  Future<void> clearConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_configKey);
  }
}
