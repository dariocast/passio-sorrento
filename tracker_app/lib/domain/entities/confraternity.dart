/// Represents a Confraternity from the server.
class Confraternity {
  final String id;
  final String name;
  final String color;
  final String municipality;
  final String? coatOfArms;
  final String? history;

  const Confraternity({
    required this.id,
    required this.name,
    required this.color,
    required this.municipality,
    this.coatOfArms,
    this.history,
  });

  factory Confraternity.fromJson(Map<String, dynamic> json) {
    return Confraternity(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      municipality: json['municipality'] as String,
      coatOfArms: json['coat_of_arms'] as String?,
      history: json['history'] as String?,
    );
  }

  @override
  String toString() => name;
}
