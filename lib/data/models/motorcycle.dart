class Motorcycle {
  final int? id;
  final String brand;
  final String model;
  final String year;  
  final String description; 

  Motorcycle({
    this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'description': description,
    };
  }

  factory Motorcycle.fromMap(Map<String, dynamic> map) {
    return Motorcycle(
      id: map['id'],
      brand: map['brand'],
      model: map['model'],
      year: map['year'],
      description: map['description'],
    );
  }
}
