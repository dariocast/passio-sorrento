/// Procession entity representing a Holy Week event.
library;

import 'package:equatable/equatable.dart';

/// Represents a procession event.
class Procession extends Equatable {
  const Procession({
    required this.id,
    required this.confraternityId,
    required this.day,
    required this.exitTime,
    this.expectedReturnTime,
    this.isLive = false,
  });

  /// Unique identifier.
  final String id;

  /// Reference to the parent confraternity.
  final String confraternityId;

  /// Day of the procession (e.g., "Holy Thursday", "Good Friday").
  final String day;

  /// Scheduled exit time.
  final DateTime exitTime;

  /// Expected return time.
  final DateTime? expectedReturnTime;

  /// Whether the procession is currently active/live.
  final bool isLive;

  @override
  List<Object?> get props => [
        id,
        confraternityId,
        day,
        exitTime,
        expectedReturnTime,
        isLive,
      ];
}
