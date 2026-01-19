/// Home remote data source.
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/constants.dart';

/// Remote data source for home feature data.
class HomeRemoteDataSource {
  HomeRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  /// Fetches confraternities from the API.
  Future<List<Map<String, dynamic>>> getConfraternities() async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.confraternities}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load confraternities');
    }
  }

  /// Fetches live processions from the API.
  Future<List<Map<String, dynamic>>> getLiveProcessions() async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.processionsLive}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load live processions');
    }
  }
}
