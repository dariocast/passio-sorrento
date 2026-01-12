/// Confraternity data model for API serialization.
library;

import '../../domain/entities/confraternity.dart';

/// Data model for [Confraternity] that handles JSON serialization.
/// 
/// This class maps the API response to the domain entity.
/// JSON keys match the API Reference specification:
/// - `id`: Unique identifier
/// - `name`: Official name
/// - `color`: Hex color string (e.g., "#000000")
/// - `municipality`: City/town name
/// - `coat_of_arms`: URL to coat of arms image (optional)
/// - `history`: Historical description (optional)
class ConfraternityModel extends Confraternity {
  const ConfraternityModel({
    required super.id,
    required super.name,
    required super.color,
    required super.municipality,
    super.coatOfArms,
    super.history,
  });

  /// Creates a [ConfraternityModel] from a JSON map.
  /// 
  /// Expects keys as defined in the API Reference:
  /// ```json
  /// {
  ///   "id": "uuid-1",
  ///   "name": "Arciconfraternita della Morte",
  ///   "color": "#000000",
  ///   "municipality": "Sorrento",
  ///   "coat_of_arms": "url/to/image.png",
  ///   "history": "Fondato nel..."
  /// }
  /// ```
  factory ConfraternityModel.fromJson(Map<String, dynamic> json) {
    return ConfraternityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      municipality: json['municipality'] as String,
      coatOfArms: json['coat_of_arms'] as String?,
      history: json['history'] as String?,
    );
  }

  /// Converts the model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'municipality': municipality,
      'coat_of_arms': coatOfArms,
      'history': history,
    };
  }

  /// Creates a [ConfraternityModel] from a domain [Confraternity] entity.
  factory ConfraternityModel.fromEntity(Confraternity entity) {
    return ConfraternityModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      municipality: entity.municipality,
      coatOfArms: entity.coatOfArms,
      history: entity.history,
    );
  }
}
