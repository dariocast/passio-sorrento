/// Confraternity entity representing a religious brotherhood.
library;

import 'package:equatable/equatable.dart';

/// Represents a Confraternity of the Sorrento Peninsula.
class Confraternity extends Equatable {
  const Confraternity({
    required this.id,
    required this.name,
    required this.color,
    required this.municipality,
    this.coatOfArms,
    this.history,
  });

  /// Unique identifier.
  final String id;

  /// Official name of the confraternity.
  final String name;

  /// Identifying color (hex string, e.g., "#000000").
  final String color;

  /// Municipality where the confraternity is based.
  final String municipality;

  /// URL or path to the coat of arms image.
  final String? coatOfArms;

  /// Historical description.
  final String? history;

  @override
  List<Object?> get props => [id, name, color, municipality, coatOfArms, history];
}
