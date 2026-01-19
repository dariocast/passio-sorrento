/// Weather Cubit for managing weather screen state.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';

part 'weather_state.dart';

/// Cubit for managing weather screen state.
class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit({required WeatherRepository repository})
    : _repository = repository,
      super(const WeatherState());

  final WeatherRepository _repository;

  /// Loads weather for a municipality.
  Future<void> loadWeather(String municipality) async {
    emit(state.copyWith(status: WeatherStatus.loading));

    try {
      final weather = await _repository.getCurrentWeather(municipality);
      final forecast = await _repository.getForecast(municipality);

      emit(
        state.copyWith(
          status: WeatherStatus.success,
          currentWeather: weather,
          forecast: forecast,
          selectedMunicipality: municipality,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WeatherStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Changes the selected municipality.
  Future<void> selectMunicipality(String municipality) async {
    await loadWeather(municipality);
  }
}
