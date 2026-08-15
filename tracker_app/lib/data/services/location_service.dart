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

  /// Request location and notification permissions.
  /// Returns true if permission is granted.
  Future<PermissionResult> requestPermission() async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const PermissionResult(
        granted: false,
        message: 'I servizi di localizzazione sono disattivati. Attiva il GPS.',
      );
    }

    // Request notification permission (required on Android 13+ for foreground service)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Check location permission status
    var status = await Permission.locationWhenInUse.status;

    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }

    if (status.isPermanentlyDenied) {
      return const PermissionResult(
        granted: false,
        message:
            'Permesso di localizzazione negato permanentemente. Abilitalo nelle impostazioni.',
        openSettings: true,
      );
    }

    if (status.isGranted) {
      return const PermissionResult(granted: true);
    }

    return const PermissionResult(
      granted: false,
      message: 'Permesso di localizzazione negato.',
    );
  }

  /// Get the current position.
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Start listening for position updates at the specified interval.
  /// Uses Android Foreground Service with ongoing notification for reliable background tracking.
  void startTracking({
    required int intervalSeconds,
    String confraternityName = 'Confraternita',
  }) {
    _positionSubscription?.cancel();

    // Use Geolocator stream with Android Foreground Service notification config
    final androidSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
      forceLocationManager: false,
      intervalDuration: Duration(seconds: intervalSeconds),
      foregroundNotificationConfig: ForegroundNotificationConfig(
        notificationTitle: 'Tracciamento Processione Attivo',
        notificationText: '$confraternityName — invio coordinate GPS in corso',
        notificationIcon: const AndroidResource(
          name: 'ic_launcher',
          defType: 'mipmap',
        ),
        enableWakeLock: true,
        setOngoing: true,
      ),
    );

    // Initial immediate position fetch
    getCurrentPosition().then((pos) {
      _positionController.add(pos);
    }).catchError((e) {
      _positionController.addError(e);
    });

    // Start foreground position stream
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: androidSettings,
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
