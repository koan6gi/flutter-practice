import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/models/motorcycle.dart';

class MotoProvider with ChangeNotifier {
  List<Motorcycle> _items = [];

  List<Motorcycle> get items => _items;

  Future<void> fetchAndSetMotorcycles() async {
    _items = await DatabaseHelper.instance.readAll();
    notifyListeners(); 
  }

  Future<void> addMoto(String brand, String model, String year, String desc) async {
    final newMoto = Motorcycle(
      brand: brand, 
      model: model, 
      year: year, 
      description: desc
    );
    await DatabaseHelper.instance.create(newMoto);
    await fetchAndSetMotorcycles(); 
  }

  Future<void> deleteMoto(int id) async {
    await DatabaseHelper.instance.delete(id);
    await fetchAndSetMotorcycles();
  }
  
  Future<void> updateMoto(Motorcycle moto) async {
    await DatabaseHelper.instance.update(moto);
    await fetchAndSetMotorcycles();
  }
}
