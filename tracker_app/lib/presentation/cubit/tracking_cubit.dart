import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/services/config_service.dart';
import '../../data/services/location_service.dart';
import '../../data/services/offline_queue_service.dart';
import '../../domain/entities/confraternity.dart';
import '../../domain/repositories/tracking_repository.dart';
import 'tracking_state.dart';

/// Cubit for managing tracking state.
///
/// Depends on [TrackingRepository] abstraction (not ApiClient directly),
/// [ConfigService] for persisting configuration,
/// [LocationService] for GPS updates, and
/// [OfflineQueueService] for buffering positions when offline.
class TrackingCubit extends Cubit<TrackingState> {
  final ConfigService _configService;
  final LocationService _locationService;
  final OfflineQueueService _offlineQueue;
  TrackingRepository? _repository;

  /// Factory function to create a new [TrackingRepository] given a server URL.
  final TrackingRepository Function(String serverUrl) _repositoryFactory;

  StreamSubscription<Position>? _positionSubscription;

  TrackingCubit({
    required ConfigService configService,
    required LocationService locationService,
    required OfflineQueueService offlineQueueService,
    required TrackingRepository Function(String serverUrl) repositoryFactory,
  }) : _configService = configService,
       _locationService = locationService,
       _offlineQueue = offlineQueueService,
       _repositoryFactory = repositoryFactory,
       super(const TrackingInitial());

  /// Initialize the cubit, loading saved configuration.
  Future<void> initialize() async {
    try {
      final config = await _configService.loadConfig();
      _repository = _repositoryFactory(config.serverUrl);

      List<Confraternity> confraternities = [];
      try {
        confraternities = await _repository!.fetchConfraternities();
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
    _repository?.dispose();
    _repository = _repositoryFactory(url);

    emit(currentState.copyWith(config: newConfig));
    await _configService.saveConfig(newConfig);

    await fetchConfraternities();
  }

  /// Fetch confraternities from the server.
  Future<void> fetchConfraternities() async {
    final currentState = state;
    if (currentState is! TrackingConfigured) return;

    try {
      final confraternities = await _repository!.fetchConfraternities();
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

  /// Test the server connection and secret.
  Future<void> testConnection() async {
    final currentState = state;
    if (currentState is! TrackingConfigured) return;

    emit(currentState.copyWith(isTestingConnection: true, connectionStatusMessage: 'Verifica in corso...'));
    try {
      final confraternities = await _repository!.fetchConfraternities();
      emit(currentState.copyWith(
        isTestingConnection: false,
        confraternities: confraternities.isNotEmpty ? confraternities : currentState.confraternities,
        isConnectionOk: true,
        connectionStatusMessage: 'Connessione al server riuscita (${confraternities.length} confraternite)',
        errorMessage: null,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isTestingConnection: false,
        isConnectionOk: false,
        connectionStatusMessage: 'Errore di connessione: $e',
      ));
    }
  }

  /// Start tracking.
  Future<void> startTracking() async {
    final currentState = state;
    if (currentState is! TrackingConfigured) return;

    final config = currentState.config;

    if (config.confraternityId.isEmpty) {
      emit(
        currentState.copyWith(errorMessage: 'Seleziona una confraternita'),
      );
      return;
    }

    if (config.secret.isEmpty) {
      emit(
        currentState.copyWith(
          errorMessage: 'Inserisci il secret di autenticazione',
        ),
      );
      return;
    }

    final permissionResult = await _locationService.requestPermission();
    if (!permissionResult.granted) {
      emit(currentState.copyWith(errorMessage: permissionResult.message));
      return;
    }

    _locationService.startTracking(
      intervalSeconds: config.intervalSeconds,
      confraternityName: config.confraternityName.isNotEmpty
          ? config.confraternityName
          : 'Confraternita',
    );

    _positionSubscription = _locationService.positionStream.listen(
      _onPositionUpdate,
      onError: _onPositionError,
    );

    final queuedCount = await _offlineQueue.queueLength;
    emit(TrackingActive(config: config, queuedCount: queuedCount));
  }

  /// Handle position update — send to server or buffer offline.
  Future<void> _onPositionUpdate(Position position) async {
    final currentState = state;
    if (currentState is! TrackingActive) return;

    try {
      final result = await _repository!.logPosition(
        confraternityId: currentState.config.confraternityId,
        latitude: position.latitude,
        longitude: position.longitude,
        secret: currentState.config.secret,
      );

      if (result.success) {
        // Position sent successfully — try to flush offline queue
        await _flushOfflineQueue(currentState);

        final queuedCount = await _offlineQueue.queueLength;
        emit(
          currentState.copyWith(
            lastPosition: position,
            lastUpdateTime: DateTime.now(),
            successCount: currentState.successCount + 1,
            queuedCount: queuedCount,
            lastError: null,
          ),
        );
      } else {
        // Server rejected the position (e.g. invalid secret)
        emit(
          currentState.copyWith(
            failureCount: currentState.failureCount + 1,
            lastError: result.error,
          ),
        );
      }
    } catch (e) {
      // Network error — buffer position offline
      await _offlineQueue.enqueue(
        QueuedPosition(
          confraternityId: currentState.config.confraternityId,
          latitude: position.latitude,
          longitude: position.longitude,
          secret: currentState.config.secret,
          timestamp: DateTime.now(),
        ),
      );

      final queuedCount = await _offlineQueue.queueLength;
      emit(
        currentState.copyWith(
          lastPosition: position,
          lastUpdateTime: DateTime.now(),
          failureCount: currentState.failureCount + 1,
          queuedCount: queuedCount,
          lastError: 'Offline — position buffered ($queuedCount queued)',
        ),
      );
    }
  }

  /// Attempt to send all queued offline positions to the server.
  Future<void> _flushOfflineQueue(TrackingActive currentState) async {
    final queue = await _offlineQueue.getQueue();
    if (queue.isEmpty) return;

    int sentCount = 0;
    for (final position in queue) {
      try {
        final result = await _repository!.logPosition(
          confraternityId: position.confraternityId,
          latitude: position.latitude,
          longitude: position.longitude,
          secret: position.secret,
        );
        if (result.success) {
          sentCount++;
        } else {
          break; // Stop flushing on server error
        }
      } catch (e) {
        break; // Stop flushing on network error
      }
    }

    if (sentCount > 0) {
      await _offlineQueue.dequeue(sentCount);
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
        confraternities = await _repository!.fetchConfraternities();
      } catch (e) {
        // Ignore — we still transition to configured state
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
    _repository?.dispose();
    return super.close();
  }
}
