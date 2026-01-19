/// Weather entity.
library;

import 'package:equatable/equatable.dart';

/// Represents weather data for a municipality.
class Weather extends Equatable {
  const Weather({
    required this.municipality,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.precipitationProbability,
    required this.humidity,
    this.feelsLike,
    required this.windSpeed,
    this.windDeg,
    required this.timestamp,
  });

  /// Municipality name.
  final String municipality;

  /// Current temperature in Celsius.
  final double temperature;

  /// Weather description (e.g., "Cloudy").
  final String description;

  /// Weather icon code.
  final String icon;

  /// Precipitation probability (0-100).
  final int precipitationProbability;

  /// Humidity percentage (0-100).
  final int humidity;

  /// Feels like temperature in Celsius.
  final double? feelsLike;

  /// Wind speed in m/s.
  final double windSpeed;

  /// Wind direction in degrees.
  final int? windDeg;

  /// Timestamp of the weather data.
  final DateTime timestamp;

  @override
  List<Object?> get props => [
    municipality,
    temperature,
    description,
    icon,
    precipitationProbability,
    humidity,
    feelsLike,
    windSpeed,
    windDeg,
    timestamp,
  ];
}
