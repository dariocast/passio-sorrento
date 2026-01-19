import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/api/api_client.dart';
import '../../data/services/config_service.dart';
import '../../data/services/location_service.dart';
import '../../domain/entities/confraternity.dart';
import '../../domain/entities/tracking_config.dart';
import 'tracking_state.dart';

/// Cubit for managing tracking state.
class TrackingCubit extends Cubit<TrackingState> {
  final ConfigService _configService;
  final LocationService _locationService;
  ApiClient? _apiClient;
  StreamSubscription<Position>? _positionSubscription;

  TrackingCubit({
    required ConfigService configService,
    required LocationService locationService,
  }) : _configService = configService,
       _locationService = locationService,
       super(const TrackingInitial());

  /// Initialize the cubit, loading saved configuration.
  Future<void> initialize() async {
    try {
      final config = await _configService.loadConfig();
      _apiClient = ApiClient(baseUrl: config.serverUrl);

      List<Confraternity> confraternities = [];
      try {
        confraternities = await _apiClient!.fetchConfraternities();
      } catch (e) {
        // Continue without confraternities, user can retry
      }

      emit(
        TrackingConfigured(config: config, confraternities: confraternities),
      );
    } catch (e) {
      emit(TrackingError(message: 'Failed to load configuration: $e'));
    }
  }

  /// Update the server URL and fetch confraternities.
  Future<void> updateServerUrl(String url) async {
    final currentState = state;
    if (currentState is! TrackingConfigured) return;

    final newConfig = currentState.config.copyWith(serverUrl: url);
    _apiClient = ApiClient(baseUrl: url);

    emit(currentState.copyWith(config: newConfig));
    await _configService.saveConfig(newConfig);

    // Try to fetch confraternities with new URL
    await fetchConfraternities();
  }

  /// Fetch confraternities from the server.
  Future<void> fetchConfraternities() async {
    final currentState = state;
    if (currentState is! TrackingConfigured) return;

    try {
      final confraternities = await _apiClient!.fetchConfraternities();
      emit(
        currentState.copyWith(
          confraternities: confraternities,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          errorMessage: 'Failed to fetch confraternities: $e',
        ),
      );
    }
  }

  /// Update configuration.
  Future<void> updateConfig({
    String? confraternityId,
    String? confraternityName,
    String? secret,
    int? intervalSeconds,
  }) async {
    final currentState = state;
    if (currentState is! TrackingConfigured) return;

    final newConfig = currentState.config.copyWith(
      confraternityId: confraternityId,
      confraternityName: confraternityName,
      secret: secret,
      intervalSeconds: intervalSeconds,
    );

    emit(currentState.copyWith(config: newConfig));
    await _configService.saveConfig(newConfig);
  }

  /// Start tracking.
  Future<void> startTracking() async {
    final currentState = state;
    if (currentState is! TrackingConfigured) return;

    final config = currentState.config;

    // Validate configuration
    if (config.confraternityId.isEmpty) {
      emit(
        currentState.copyWith(errorMessage: 'Please select a confraternity'),
      );
      return;
    }

    if (config.secret.isEmpty) {
      emit(
        currentState.copyWith(
          errorMessage: 'Please enter the authentication secret',
        ),
      );
      return;
    }

    // Request location permission
    final permissionResult = await _locationService.requestPermission();
    if (!permissionResult.granted) {
      emit(currentState.copyWith(errorMessage: permissionResult.message));
      return;
    }

    // Start location tracking
    _locationService.startTracking(intervalSeconds: config.intervalSeconds);

    // Listen to position updates
    _positionSubscription = _locationService.positionStream.listen(
      _onPositionUpdate,
      onError: _onPositionError,
    );

    emit(TrackingActive(config: config));
  }

  /// Handle position update.
  Future<void> _onPositionUpdate(Position position) async {
    final currentState = state;
    if (currentState is! TrackingActive) return;

    // Send position to server
    try {
      final result = await _apiClient!.logPosition(
        confraternityId: currentState.config.confraternityId,
        latitude: position.latitude,
        longitude: position.longitude,
        secret: currentState.config.secret,
      );

      if (result.success) {
        emit(
          currentState.copyWith(
            lastPosition: position,
            lastUpdateTime: DateTime.now(),
            successCount: currentState.successCount + 1,
            lastError: null,
          ),
        );
      } else {
        emit(
          currentState.copyWith(
            failureCount: currentState.failureCount + 1,
            lastError: result.error,
          ),
        );
      }
    } catch (e) {
      emit(
        currentState.copyWith(
          failureCount: currentState.failureCount + 1,
          lastError: e.toString(),
        ),
      );
    }
  }

  /// Handle position error.
  void _onPositionError(dynamic error) {
    final currentState = state;
    if (currentState is! TrackingActive) return;

    emit(
      currentState.copyWith(
        failureCount: currentState.failureCount + 1,
        lastError: 'Location error: $error',
      ),
    );
  }

  /// Stop tracking.
  Future<void> stopTracking() async {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _locationService.stopTracking();

    final currentState = state;
    if (currentState is TrackingActive) {
      final config = await _configService.loadConfig();
      List<Confraternity> confraternities = [];
      try {
        confraternities = await _apiClient!.fetchConfraternities();
      } catch (e) {
        // Ignore
      }

      emit(
        TrackingConfigured(config: config, confraternities: confraternities),
      );
    }
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _locationService.dispose();
    _apiClient?.dispose();
    return super.close();
  }
}
