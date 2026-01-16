/// Tracking entity representing a procession's live location.
library;

import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// Represents the live tracking data of a procession.
class TrackingData extends Equatable {
  const TrackingData({
    required this.processionId,
    required this.position,
    required this.timestamp,
    required this.lastUpdate,
    required this.color,
    this.name,
  });

  /// Reference to the procession/confraternity being tracked.
  final String processionId;

  /// Current geographic position.
  final LatLng position;

  /// Timestamp when tracking started.
  final DateTime timestamp;

  /// Last update timestamp.
  final DateTime lastUpdate;

  /// Confraternity color in hex format (e.g., "#000000").
  final String color;

  /// Confraternity name (optional).
  final String? name;

  @override
  List<Object?> get props => [
    processionId,
    position,
    timestamp,
    lastUpdate,
    color,
    name,
  ];
}
