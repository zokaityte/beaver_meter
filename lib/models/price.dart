class Price {
  final int? id;
  final double pricePerUnit;
  final double basePrice;
  final String validFrom;
  final String validTo;
  final int meterId;

  Price({
    this.id,
    required this.pricePerUnit,
    required this.basePrice,
    required this.validFrom,
    required this.validTo,
    required this.meterId,
  });

  factory Price.fromMap(Map<String, dynamic> map) {
    return Price(
      id: map['id'],
      pricePerUnit: map['price_per_unit'],
      basePrice: map['base_price'],
      validFrom: map['valid_from'],
      validTo: map['valid_to'],
      meterId: map['meter_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'price_per_unit': pricePerUnit,
      'base_price': basePrice,
      'valid_from': validFrom,
      'valid_to': validTo,
      'meter_id': meterId,
    };
  }
}
