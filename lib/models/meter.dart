class Meter {
  final int? id;
  final String name;
  final String unit;
  final int color; // id of color from config.dart
  final int icon;

  Meter({
    this.id,
    required this.name,
    required this.unit,
    required this.color,
    required this.icon
  });

  // Convert a Map to a Meter object
  factory Meter.fromMap(Map<String, dynamic> map) {
    return Meter(
      id: map['id'],
      name: map['name'],
      unit: map['unit'],
      color: map['color'],
      icon: map['icon']
    );
  }

  // Convert a Meter object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'color': color,
      'icon': icon
    };
  }
}
