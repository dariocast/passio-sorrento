import '../../domain/entities/confraternity.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../api/api_client.dart';

/// Concrete implementation of [TrackingRepository] using [ApiClient].
///
/// This class bridges the domain interface with the HTTP layer.
/// It delegates all calls to the [ApiClient] and maps results
/// to domain-level types.
class TrackingRepositoryImpl implements TrackingRepository {
  final ApiClient _apiClient;

  TrackingRepositoryImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<Confraternity>> fetchConfraternities() {
    return _apiClient.fetchConfraternities();
  }

  @override
  Future<LogPositionResult> logPosition({
    required String confraternityId,
    required double latitude,
    required double longitude,
    required String secret,
  }) async {
    final apiResult = await _apiClient.logPosition(
      confraternityId: confraternityId,
      latitude: latitude,
      longitude: longitude,
      secret: secret,
    );

    return LogPositionResult(
      success: apiResult.success,
      id: apiResult.id,
      timestamp: apiResult.timestamp,
      error: apiResult.error,
    );
  }

  @override
  void dispose() {
    _apiClient.dispose();
  }
}
