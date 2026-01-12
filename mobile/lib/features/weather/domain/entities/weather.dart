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

  /// Timestamp of the weather data.
  final DateTime timestamp;

  @override
  List<Object?> get props => [
        municipality,
        temperature,
        description,
        icon,
        precipitationProbability,
        timestamp,
      ];
}
