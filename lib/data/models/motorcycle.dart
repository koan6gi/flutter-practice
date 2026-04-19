class Motorcycle {
  final int? id;
  final String make;
  final String model;
  final int year;  
  final String type;
  final String engine;
  final String power;
  final String transmission;
  final String weight;

  Motorcycle({
    this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.type,
    required this.engine,
    required this.power,
    required this.transmission,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'type': type,
      'engine': engine,
      'power': power,
      'transmission': transmission,
      'weight': weight,
    };
  }

  factory Motorcycle.fromMap(Map<String, dynamic> map) {
    int parsedYear = 0;
    if (map['year'] != null) {
      parsedYear = int.tryParse(map['year'].toString()) ?? 0;
    }

    return Motorcycle(
      id: map['id'],
      make: map['make'] ?? map['brand'] ?? 'Unknown',
      model: map['model'] ?? 'Unknown',
      year: parsedYear,
      type: map['type'] ?? 'N/A',
      engine: map['engine'] ?? 'N/A',
      power: map['power'] ?? 'N/A',
      transmission: map['transmission'] ?? 'N/A',
      weight: map['total_weight'] ?? map['weight'] ?? 'N/A',
    );
  }
}