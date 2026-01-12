part of 'tracking_cubit.dart';

/// Status for tracking loading.
enum TrackingStatus { initial, loading, success, failure }

/// State for the tracking screen.
class TrackingState extends Equatable {
  const TrackingState({
    this.status = TrackingStatus.initial,
    this.trackingData = const [],
    this.selectedProcessionId,
    this.errorMessage,
  });

  /// Current loading status.
  final TrackingStatus status;

  /// List of live tracking data.
  final List<TrackingData> trackingData;

  /// Currently selected procession ID for map focus.
  final String? selectedProcessionId;

  /// Error message if any.
  final String? errorMessage;

  /// Creates a copy with updated fields.
  TrackingState copyWith({
    TrackingStatus? status,
    List<TrackingData>? trackingData,
    String? selectedProcessionId,
    String? errorMessage,
  }) {
    return TrackingState(
      status: status ?? this.status,
      trackingData: trackingData ?? this.trackingData,
      selectedProcessionId: selectedProcessionId ?? this.selectedProcessionId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, trackingData, selectedProcessionId, errorMessage];
}
