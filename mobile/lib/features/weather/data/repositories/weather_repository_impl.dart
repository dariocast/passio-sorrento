/// Weather repository implementation.
library;

import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_data_source.dart';

/// Implementation of [WeatherRepository].
class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl({required WeatherRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final WeatherRemoteDataSource _remoteDataSource;

  @override
  Future<Weather> getCurrentWeather(String municipality) async {
    final data = await _remoteDataSource.getCurrentWeather(municipality);
    return _weatherFromJson(municipality, data);
  }

  @override
  Future<List<Weather>> getForecast(String municipality) async {
    final data = await _remoteDataSource.getForecast(municipality);
    final list = data['list'] as List<dynamic>;
    return list
        .map((item) => _weatherFromJson(municipality, item as Map<String, dynamic>))
        .toList();
  }

  Weather _weatherFromJson(String municipality, Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List<dynamic>).first as Map<String, dynamic>;
    
    return Weather(
      municipality: municipality,
      temperature: (main['temp'] as num).toDouble(),
      description: weather['description'] as String,
      icon: weather['icon'] as String,
      precipitationProbability: ((json['pop'] as num?) ?? 0 * 100).toInt(),
      timestamp: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
    );
  }
}
