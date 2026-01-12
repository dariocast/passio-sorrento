/// Tracking remote data source.
library;

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/constants.dart';

/// Remote data source for tracking data.
class TrackingRemoteDataSource {
  TrackingRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Fetches live tracking data for all active processions.
  Future<List<Map<String, dynamic>>> getLiveTrackingData() async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.processionsLive}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load tracking data');
    }
  }
}
