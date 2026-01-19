/// Weather remote data source.
library;

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Remote data source for weather data (OpenWeatherMap API).
class WeatherRemoteDataSource {
  WeatherRemoteDataSource({required String apiKey, http.Client? client})
    : _apiKey = apiKey,
      _client = client ?? http.Client();

  final String _apiKey;
  final http.Client _client;

  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// Fetches current weather for a municipality.
  Future<Map<String, dynamic>> getCurrentWeather(String municipality) async {
    final response = await _client.get(
      Uri.parse(
        '$_baseUrl/weather?q=$municipality,IT&appid=$_apiKey&units=metric',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  /// Fetches weather forecast for a municipality.
  Future<Map<String, dynamic>> getForecast(String municipality) async {
    final response = await _client.get(
      Uri.parse(
        '$_baseUrl/forecast?q=$municipality,IT&appid=$_apiKey&units=metric',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load forecast data');
    }
  }
}
