import '../entities/confraternity.dart';

/// Result of a position log request.
class LogPositionResult {
  final bool success;
  final int? id;
  final String? timestamp;
  final String? error;

  const LogPositionResult({
    required this.success,
    this.id,
    this.timestamp,
    this.error,
  });
}

/// Abstract interface for tracking-related server operations.
///
/// Implemented by [TrackingRepositoryImpl] in the data layer.
/// The presentation layer depends on this abstraction, not its implementation.
abstract class TrackingRepository {
  /// Fetches all confraternities from the server.
  Future<List<Confraternity>> fetchConfraternities();

  /// Logs a GPS position for a confraternity.
  ///
  /// Returns a [LogPositionResult] indicating success or failure.
  Future<LogPositionResult> logPosition({
    required String confraternityId,
    required double latitude,
    required double longitude,
    required String secret,
  });

  /// Disposes of any resources held by this repository.
  void dispose();
}
