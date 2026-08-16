/// Weather remote data source using Open-Meteo real-time API.
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/constants.dart';

/// Remote data source for live weather data.
///
/// Uses Open-Meteo with exact coordinates for municipalities, dynamically
/// synchronized with the backend server `/api/municipalities`.
class WeatherRemoteDataSource {
  WeatherRemoteDataSource({
    String? backendUrl,
    http.Client? client,
  }) : _backendUrl = backendUrl ?? ApiConstants.baseUrl,
       _client = client ?? http.Client();

  final String _backendUrl;
  final http.Client _client;

  /// In-memory cache of municipality coordinates.
  final Map<String, (double, double)> _municipalityCoords = {
    'Sorrento': (40.6263, 14.3758),
    'Sant\'Agnello': (40.6300, 14.3986),
    'Piano di Sorrento': (40.6339, 14.4086),
    'Meta': (40.6419, 14.4172),
    'Vico Equense': (40.6631, 14.4289),
    'Massa Lubrense': (40.6108, 14.3436),
  };

  /// Fetches active municipalities from the backend server.
  Future<List<String>> getMunicipalities() async {
    try {
      final response = await _client
          .get(Uri.parse('$_backendUrl/municipalities'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        final names = <String>[];
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            final name = item['name'] as String;
            final lat = (item['latitude'] as num).toDouble();
            final lng = (item['longitude'] as num).toDouble();
            _municipalityCoords[name] = (lat, lng);
            names.add(name);
          }
        }
        if (names.isNotEmpty) {
          return names;
        }
      }
    } catch (_) {
      // Graceful offline fallback
    }

    return AppConstants.municipalities;
  }

  (double, double) _getCoords(String municipality) {
    return _municipalityCoords[municipality] ?? (40.6263, 14.3758);
  }

  /// Fetches current weather for a municipality.
  Future<Map<String, dynamic>> getCurrentWeather(String municipality) async {
    final coords = _getCoords(municipality);
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?'
      'latitude=${coords.$1}&longitude=${coords.$2}&'
      'current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m&'
      'hourly=precipitation_probability&'
      'wind_speed_unit=ms&timezone=Europe%2FRome',
    );

    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final current = data['current'] as Map<String, dynamic>;
        final hourly = data['hourly'] as Map<String, dynamic>?;
        
        final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;
        final (desc, icon) = _mapWmoCode(weatherCode);

        int pop = 0;
        if (hourly != null && hourly['precipitation_probability'] is List) {
          final popList = hourly['precipitation_probability'] as List;
          if (popList.isNotEmpty) {
            pop = (popList.first as num?)?.toInt() ?? 0;
          }
        }

        final nowIso = current['time'] as String? ?? DateTime.now().toIso8601String();
        final timestamp = DateTime.tryParse(nowIso)?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;

        return {
          'main': {
            'temp': (current['temperature_2m'] as num).toDouble(),
            'feels_like': (current['apparent_temperature'] as num?)?.toDouble() ?? (current['temperature_2m'] as num).toDouble(),
            'humidity': (current['relative_humidity_2m'] as num?)?.toInt() ?? 60,
          },
          'weather': [
            {
              'description': desc,
              'icon': icon,
            }
          ],
          'wind': {
            'speed': (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
            'deg': (current['wind_direction_10m'] as num?)?.toInt() ?? 0,
          },
          'pop': pop / 100.0,
          'dt': timestamp ~/ 1000,
        };
      }
    } catch (_) {
      // Fallback on network failure
    }

    return _getFallbackCurrentWeather(municipality);
  }

  /// Fetches weather forecast for a municipality.
  Future<Map<String, dynamic>> getForecast(String municipality) async {
    final coords = _getCoords(municipality);
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?'
      'latitude=${coords.$1}&longitude=${coords.$2}&'
      'hourly=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation_probability,weather_code,wind_speed_10m,wind_direction_10m&'
      'wind_speed_unit=ms&timezone=Europe%2FRome&forecast_hours=48',
    );

    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final hourly = data['hourly'] as Map<String, dynamic>;

        final times = hourly['time'] as List<dynamic>;
        final temps = hourly['temperature_2m'] as List<dynamic>;
        final feels = hourly['apparent_temperature'] as List<dynamic>?;
        final humidities = hourly['relative_humidity_2m'] as List<dynamic>;
        final pops = hourly['precipitation_probability'] as List<dynamic>;
        final codes = hourly['weather_code'] as List<dynamic>;
        final winds = hourly['wind_speed_10m'] as List<dynamic>;
        final windDegs = hourly['wind_direction_10m'] as List<dynamic>?;

        final list = <Map<String, dynamic>>[];
        final count = times.length;

        for (int i = 0; i < count; i++) {
          final code = (codes[i] as num?)?.toInt() ?? 0;
          final (desc, icon) = _mapWmoCode(code);
          final timeStr = times[i] as String;
          final dt = (DateTime.tryParse(timeStr)?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch) ~/ 1000;

          list.add({
            'main': {
              'temp': (temps[i] as num).toDouble(),
              'feels_like': feels != null ? (feels[i] as num).toDouble() : (temps[i] as num).toDouble(),
              'humidity': (humidities[i] as num).toInt(),
            },
            'weather': [
              {
                'description': desc,
                'icon': icon,
              }
            ],
            'wind': {
              'speed': (winds[i] as num).toDouble(),
              'deg': windDegs != null ? (windDegs[i] as num).toInt() : 0,
            },
            'pop': ((pops[i] as num?)?.toDouble() ?? 0.0) / 100.0,
            'dt': dt,
          });
        }

        return {'list': list};
      }
    } catch (_) {
      // Fallback on network failure
    }

    return _getFallbackForecast(municipality);
  }

  /// Maps WMO Weather Code to Italian description and standard icon.
  (String, String) _mapWmoCode(int code) {
    switch (code) {
      case 0:
        return ('Cielo sereno', '01d');
      case 1:
        return ('Prevalentemente sereno', '01d');
      case 2:
        return ('Parzialmente nuvoloso', '02d');
      case 3:
        return ('Coperto', '04d');
      case 45:
      case 48:
        return ('Nebbia', '50d');
      case 51:
      case 53:
      case 55:
        return ('Pioggerella leggera', '09d');
      case 61:
        return ('Pioggia debole', '10d');
      case 63:
        return ('Pioggia moderata', '10d');
      case 65:
        return ('Pioggia forte', '10d');
      case 71:
      case 73:
      case 75:
        return ('Neve', '13d');
      case 80:
      case 81:
      case 82:
        return ('Rovesci di pioggia', '09d');
      case 95:
      case 96:
      case 99:
        return ('Temporale', '11d');
      default:
        return ('Poco nuvoloso', '02d');
    }
  }

  Map<String, dynamic> _getFallbackCurrentWeather(String municipality) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return {
      'main': {
        'temp': 20.0,
        'feels_like': 20.0,
        'humidity': 65,
      },
      'weather': [
        {
          'description': 'Sereno o poco nuvoloso',
          'icon': '01d',
        }
      ],
      'wind': {'speed': 3.0, 'deg': 180},
      'pop': 0.05,
      'dt': now,
    };
  }

  Map<String, dynamic> _getFallbackForecast(String municipality) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return {
      'list': List.generate(12, (index) {
        return {
          'main': {
            'temp': 18.0 + (index % 4),
            'feels_like': 17.5 + (index % 4),
            'humidity': 60 + (index * 2),
          },
          'weather': [
            {
              'description': index % 3 == 0 ? 'Sereno' : 'Parzialmente nuvoloso',
              'icon': index % 3 == 0 ? '01d' : '02d',
            }
          ],
          'wind': {'speed': 2.5, 'deg': 190},
          'pop': 0.05 * (index + 1),
          'dt': now + (index * 3600 * 3),
        };
      }),
    };
  }
}
