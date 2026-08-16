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
    if (_apiKey.isEmpty) {
      return _getMockCurrentWeather(municipality);
    }

    final response = await _client.get(
      Uri.parse(
        '$_baseUrl/weather?q=$municipality,IT&appid=$_apiKey&units=metric&lang=it',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      return _getMockCurrentWeather(municipality);
    }
  }

  /// Fetches weather forecast for a municipality.
  Future<Map<String, dynamic>> getForecast(String municipality) async {
    if (_apiKey.isEmpty) {
      return _getMockForecast(municipality);
    }

    final response = await _client.get(
      Uri.parse(
        '$_baseUrl/forecast?q=$municipality,IT&appid=$_apiKey&units=metric&lang=it',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      return _getMockForecast(municipality);
    }
  }

  Map<String, dynamic> _getMockCurrentWeather(String municipality) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return {
      'main': {
        'temp': 16.5,
        'feels_like': 16.0,
        'humidity': 68,
      },
      'weather': [
        {
          'description': 'Sereno o poco nuvoloso',
          'icon': '01d',
        }
      ],
      'wind': {'speed': 3.2, 'deg': 180},
      'pop': 0.05,
      'dt': now,
    };
  }

  Map<String, dynamic> _getMockForecast(String municipality) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return {
      'list': List.generate(8, (index) {
        return {
          'main': {
            'temp': 15.0 + (index % 3),
            'feels_like': 14.5 + (index % 3),
            'humidity': 65 + (index * 2),
          },
          'weather': [
            {
              'description': index % 2 == 0 ? 'Sereno' : 'Nubi sparse',
              'icon': index % 2 == 0 ? '01d' : '02d',
            }
          ],
          'wind': {'speed': 2.8, 'deg': 190},
          'pop': 0.05 * (index + 1),
          'dt': now + (index * 3600 * 3),
        };
      }),
    };
  }
}
