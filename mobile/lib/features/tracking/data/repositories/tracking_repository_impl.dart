/// Tracking repository implementation.
library;

import 'dart:async';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/constants.dart';
import '../../domain/entities/tracking_data.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../datasources/tracking_remote_data_source.dart';

/// Implementation of [TrackingRepository].
class TrackingRepositoryImpl implements TrackingRepository {
  TrackingRepositoryImpl({required TrackingRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final TrackingRemoteDataSource _remoteDataSource;
  final _trackingController = StreamController<List<TrackingData>>.broadcast();
  Timer? _pollingTimer;

  @override
  Future<List<TrackingData>> getLiveTrackingData() async {
    final data = await _remoteDataSource.getLiveTrackingData();
    return data.map((json) => _trackingDataFromJson(json)).toList();
  }

  @override
  Future<TrackingData?> getTrackingDataForProcession(
    String processionId,
  ) async {
    final allData = await getLiveTrackingData();
    return allData.where((d) => d.processionId == processionId).firstOrNull;
  }

  @override
  Stream<List<TrackingData>> watchLiveTrackingData() {
    _startPolling();
    return _trackingController.stream;
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      Duration(seconds: AppConstants.trackingPollingIntervalSeconds),
      (_) async {
        try {
          final data = await getLiveTrackingData();
          _trackingController.add(data);
        } catch (e) {
          _trackingController.addError(e);
        }
      },
    );
  }

  /// Stops the polling timer. Call this when disposing.
  void dispose() {
    _pollingTimer?.cancel();
    _trackingController.close();
  }

  TrackingData _trackingDataFromJson(Map<String, dynamic> json) {
    // Map from /tracking/live response format
    // API returns: confraternity_id, lat, lng, last_updated, confraternity_name, confraternity_color
    final timestamp = json['last_updated'] as String;
    return TrackingData(
      processionId: json['confraternity_id'] as String,
      position: LatLng(
        (json['lat'] as num).toDouble(),
        (json['lng'] as num).toDouble(),
      ),
      timestamp: DateTime.parse(timestamp.replaceAll('Z', '')),
      lastUpdate: DateTime.parse(timestamp.replaceAll('Z', '')),
      color: json['confraternity_color'] as String? ?? '#5C1A1B',
      name: json['confraternity_name'] as String?,
    );
  }
}
