import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data/database_helper.dart';
import '../data/models/motorcycle.dart';

class MotoProvider with ChangeNotifier {
  List<Motorcycle> _collection = [];
  List<Motorcycle> _searchResults = [];
  bool _isLoading = false;

  List<Motorcycle> get collection => _collection;
  List<Motorcycle> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  Future<void> loadCollection() async {
    _collection = await DatabaseHelper.instance.readAll();
    notifyListeners();
  }

  Future<String?> searchMotorcycles(String query) async {
    if (query.isEmpty) return 'enterQuery';

    _isLoading = true;
    notifyListeners();

    String? statusKey;
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOffline = connectivityResult == ConnectivityResult.none;

    if (isOffline) {
      statusKey = 'networkError';
      _searchResults = [];
    } else {
      final apiKey = dotenv.env['API_NINJAS_KEY'] ?? '';
      final url = Uri.parse('https://api.api-ninjas.com/v1/motorcycles?make=$query');

      try {
        final response = await http.get(url, headers: {'X-Api-Key': apiKey});
        
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          _searchResults = data.map((json) => Motorcycle.fromMap(json)).toList();

          if (_searchResults.isEmpty) {
            statusKey = 'noResults';
          }
        } else {
          statusKey = 'apiError';
        }
      } catch (e) {
        statusKey = 'networkError';
      }
    }

    _isLoading = false;
    notifyListeners();
    return statusKey; 
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  Future<void> addToCollection(Motorcycle moto) async {
    await DatabaseHelper.instance.create(moto);
    await loadCollection();
  }

  Future<void> removeFromCollection(int id) async {
    await DatabaseHelper.instance.delete(id);
    await loadCollection();
  }
}
