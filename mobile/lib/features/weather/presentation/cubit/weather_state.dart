part of 'weather_cubit.dart';

/// Status for weather loading.
enum WeatherStatus { initial, loading, success, failure }

/// State for the weather screen.
class WeatherState extends Equatable {
  const WeatherState({
    this.status = WeatherStatus.initial,
    this.currentWeather,
    this.forecast = const [],
    this.selectedMunicipality,
    this.errorMessage,
  });

  /// Current loading status.
  final WeatherStatus status;

  /// Current weather data.
  final Weather? currentWeather;

  /// Weather forecast.
  final List<Weather> forecast;

  /// Currently selected municipality.
  final String? selectedMunicipality;

  /// Error message if any.
  final String? errorMessage;

  /// Creates a copy with updated fields.
  WeatherState copyWith({
    WeatherStatus? status,
    Weather? currentWeather,
    List<Weather>? forecast,
    String? selectedMunicipality,
    String? errorMessage,
  }) {
    return WeatherState(
      status: status ?? this.status,
      currentWeather: currentWeather ?? this.currentWeather,
      forecast: forecast ?? this.forecast,
      selectedMunicipality: selectedMunicipality ?? this.selectedMunicipality,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentWeather,
    forecast,
    selectedMunicipality,
    errorMessage,
  ];
}
