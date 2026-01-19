import 'package:geolocator/geolocator.dart';
import '../../domain/entities/confraternity.dart';
import '../../domain/entities/tracking_config.dart';

/// Base state for tracking.
sealed class TrackingState {
  const TrackingState();
}

/// Initial state, loading configuration.
class TrackingInitial extends TrackingState {
  const TrackingInitial();
}

/// Configuration loaded, ready to configure or start.
class TrackingConfigured extends TrackingState {
  final TrackingConfig config;
  final List<Confraternity> confraternities;
  final String? errorMessage;

  const TrackingConfigured({
    required this.config,
    this.confraternities = const [],
    this.errorMessage,
  });

  TrackingConfigured copyWith({
    TrackingConfig? config,
    List<Confraternity>? confraternities,
    String? errorMessage,
  }) {
    return TrackingConfigured(
      config: config ?? this.config,
      confraternities: confraternities ?? this.confraternities,
      errorMessage: errorMessage,
    );
  }
}

/// Tracking is active.
class TrackingActive extends TrackingState {
  final TrackingConfig config;
  final Position? lastPosition;
  final DateTime? lastUpdateTime;
  final int successCount;
  final int failureCount;
  final String? lastError;

  const TrackingActive({
    required this.config,
    this.lastPosition,
    this.lastUpdateTime,
    this.successCount = 0,
    this.failureCount = 0,
    this.lastError,
  });

  TrackingActive copyWith({
    TrackingConfig? config,
    Position? lastPosition,
    DateTime? lastUpdateTime,
    int? successCount,
    int? failureCount,
    String? lastError,
  }) {
    return TrackingActive(
      config: config ?? this.config,
      lastPosition: lastPosition ?? this.lastPosition,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      lastError: lastError,
    );
  }
}

/// Error state.
class TrackingError extends TrackingState {
  final String message;
  final TrackingConfig? config;
  final bool canRetry;

  const TrackingError({
    required this.message,
    this.config,
    this.canRetry = true,
  });
}
