import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/confraternity.dart';

/// API client for communication with the Holyweek Tracker server.
///
/// This is a low-level HTTP client. The presentation layer should
/// use [TrackingRepository] instead of this class directly.
class ApiClient {
  final String baseUrl;
  final http.Client _client;

  ApiClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  /// Fetches all confraternities from the server.
  Future<List<Confraternity>> fetchConfraternities() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/confraternities'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Confraternity.fromJson(json)).toList();
    } else {
      throw ApiException(
        'Failed to fetch confraternities',
        statusCode: response.statusCode,
      );
    }
  }

  /// Logs a GPS position for a confraternity.
  Future<ApiLogResult> logPosition({
    required String confraternityId,
    required double latitude,
    required double longitude,
    required String secret,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/tracking/log'),
      headers: {
        'Content-Type': 'application/json',
        'X-Capofila-Secret': secret,
      },
      body: jsonEncode({
        'confraternity_id': confraternityId,
        'lat': latitude,
        'lng': longitude,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['error'] == null) {
      return ApiLogResult(
        success: true,
        id: data['data']['id'],
        timestamp: data['data']['last_updated'],
      );
    } else {
      return ApiLogResult(
        success: false,
        error: data['error'] ?? 'Unknown error',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Internal result type for the API position log response.
///
/// This is mapped to [LogPositionResult] in the domain layer
/// by [TrackingRepositoryImpl].
class ApiLogResult {
  final bool success;
  final int? id;
  final String? timestamp;
  final String? error;

  const ApiLogResult({
    required this.success,
    this.id,
    this.timestamp,
    this.error,
  });
}

/// Exception for API errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
