/// Local data source for caching confraternity data.
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/confraternity_model.dart';

/// Local data source for caching confraternity data for offline access.
class HomeLocalDataSource {
  HomeLocalDataSource({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  static const String _confraternityKey = 'cached_confraternities';
  static const String _cacheTimestampKey = 'confraternities_cache_timestamp';

  /// Cache validity duration (24 hours).
  static const Duration cacheValidity = Duration(hours: 24);

  /// Initializes the SharedPreferences instance.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Caches the list of confraternities.
  Future<void> cacheConfraternities(List<ConfraternityModel> confraternities) async {
    await init();
    final jsonList = confraternities.map((c) => c.toJson()).toList();
    await _prefs!.setString(_confraternityKey, json.encode(jsonList));
    await _prefs!.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Gets cached confraternities.
  /// Returns null if no cache exists.
  Future<List<ConfraternityModel>?> getCachedConfraternities() async {
    await init();
    final jsonString = _prefs!.getString(_confraternityKey);
    if (jsonString == null) return null;

    try {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => ConfraternityModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Checks if the cache is still valid.
  Future<bool> isCacheValid() async {
    await init();
    final timestamp = _prefs!.getInt(_cacheTimestampKey);
    if (timestamp == null) return false;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cacheTime) < cacheValidity;
  }

  /// Clears the cache.
  Future<void> clearCache() async {
    await init();
    await _prefs!.remove(_confraternityKey);
    await _prefs!.remove(_cacheTimestampKey);
  }
}
