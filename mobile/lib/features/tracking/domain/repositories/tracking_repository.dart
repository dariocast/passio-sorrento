import 'package:latlong2/latlong.dart';
import '../entities/tracking_data.dart';

/// Repository interface for tracking data operations.
abstract class TrackingRepository {
  /// Gets live tracking data for all active processions.
  Future<List<TrackingData>> getLiveTrackingData();

  /// Gets tracking data for a specific procession.
  Future<TrackingData?> getTrackingDataForProcession(String processionId);

  /// Gets historical GPS positions for rendering the trail.
  Future<List<LatLng>> getTrackingHistory(String confraternityId);

  /// Stream of live tracking updates.
  Stream<List<TrackingData>> watchLiveTrackingData();
}
