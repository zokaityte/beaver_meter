class Reading {
  final int? id;
  final int meterId;
  final double value;
  final String date;

  Reading({
    this.id,
    required this.meterId,
    required this.value,
    required this.date,
  });

  factory Reading.fromMap(Map<String, dynamic> map) {
    return Reading(
      id: map['id'],
      meterId: map['meter_id'],
      value: map['value'],
      date: map['date'],
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

