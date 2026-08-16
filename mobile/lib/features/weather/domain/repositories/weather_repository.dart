/// Weather repository interface.
library;

import '../entities/weather.dart';

/// Repository interface for weather data operations.
abstract class WeatherRepository {
  /// Gets list of active municipalities.
  Future<List<String>> getMunicipalities();

  /// Gets current weather for a municipality.
  Future<Weather> getCurrentWeather(String municipality);

  /// Gets weather forecast for a municipality.
  Future<List<Weather>> getForecast(String municipality);
}
