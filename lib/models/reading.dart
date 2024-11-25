class Reading {
  final int? id;
  final int meterId;
  final int value;
  final String date;

  Reading({
    this.id,
    required this.meterId,
    required this.value,
    required this.date,
  });

  factory Reading.fromMap(Map<String, dynamic> map) {
    return Reading(
      id: map['id'] as int,
      meterId: map['meter_id'] as int,
      value: map['value'] as int,
      date: map['date'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meter_id': meterId,
      'value': value,
      'date': date,
    };
  }
}
