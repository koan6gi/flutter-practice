class Motorcycle {
  final String? id; 
  final String make;
  final String model;
  final int year;  
  final String type;
  final String engine;
  final String power;
  final String transmission;
  final String weight;
  final String? imageUrl; 
  final String? imageFileId;

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
    this.imageUrl,
    this.imageFileId,
  });

  Map<String, dynamic> toMap() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'type': type,
      'engine': engine,
      'power': power,
      'transmission': transmission,
      'weight': weight,
      'imageUrl': imageUrl,
      'imageFileId': imageFileId,
    };
  }

  factory Motorcycle.fromMap(Map<String, dynamic> map, {String? docId}) {
    int parsedYear = 0;
    if (map['year'] != null) {
      parsedYear = int.tryParse(map['year'].toString()) ?? 0;
    }

    return Motorcycle(
      id: docId ?? map['id']?.toString(),
      make: map['make'] ?? map['brand'] ?? 'Unknown',
      model: map['model'] ?? 'Unknown',
      year: parsedYear,
      type: map['type'] ?? 'N/A',
      engine: map['engine'] ?? 'N/A',
      power: map['power'] ?? 'N/A',
      transmission: map['transmission'] ?? 'N/A',
      weight: map['total_weight'] ?? map['weight'] ?? 'N/A',
      imageUrl: map['imageUrl'],
      imageFileId: map['imageFileId'],
    );
  }
}