import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for managing GPS location updates.
class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final _positionController = StreamController<Position>.broadcast();

  /// Stream of position updates.
  Stream<Position> get positionStream => _positionController.stream;

  /// Check if location services are enabled.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permissions.
  /// Returns true if permission is granted.
  Future<PermissionResult> requestPermission() async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return PermissionResult(
        granted: false,
        message: 'Location services are disabled. Please enable GPS.',
      );
    }

    // Check current permission status
    var status = await Permission.locationWhenInUse.status;

    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }

    if (status.isPermanentlyDenied) {
      return PermissionResult(
        granted: false,
        message:
            'Location permission permanently denied. Please enable in settings.',
        openSettings: true,
      );
    }

    if (status.isGranted) {
      return PermissionResult(granted: true);
    }

    return PermissionResult(
      granted: false,
      message: 'Location permission denied.',
    );
  }

  /// Get the current position.
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  /// Start listening for position updates at the specified interval.
  void startTracking({required int intervalSeconds}) {
    _positionSubscription?.cancel();

    // Use a timer-based approach for consistent interval updates
    Timer.periodic(Duration(seconds: intervalSeconds), (timer) async {
      if (_positionSubscription == null) {
        timer.cancel();
        return;
      }

      try {
        final position = await getCurrentPosition();
        _positionController.add(position);
      } catch (e) {
        _positionController.addError(e);
      }
    });

    // Also listen to continuous updates for accuracy
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
            forceLocationManager: false,
            intervalDuration: Duration(seconds: intervalSeconds),
          ),
        ).listen(
          (position) => _positionController.add(position),
          onError: (error) => _positionController.addError(error),
        );
  }

  /// Stop listening for position updates.
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Check if currently tracking.
  bool get isTracking => _positionSubscription != null;

  /// Dispose resources.
  void dispose() {
    stopTracking();
    _positionController.close();
  }
}

/// Result of a permission request.
class PermissionResult {
  final bool granted;
  final String? message;
  final bool openSettings;

  const PermissionResult({
    required this.granted,
    this.message,
    this.openSettings = false,
  });
}
