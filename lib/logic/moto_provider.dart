import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/motorcycle.dart';

class MotoProvider with ChangeNotifier {
  List<Motorcycle> _collection = [];
  List<Motorcycle> _searchResults = [];
  bool _isLoading = false;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Motorcycle> get collection => _collection;
  List<Motorcycle> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  Future<void> loadCollection() async {
    try {
      final snapshot = await _db.collection('garage').get();
      _collection = snapshot.docs.map((doc) {
        return Motorcycle.fromMap(doc.data(), docId: doc.id);
      }).toList();
      notifyListeners();
    } catch (e) {
      print('Error Firebase load: $e');
    }
  }

  Future<String?> searchMotorcycles(String query) async {
    if (query.isEmpty) return 'enterQuery';

    _isLoading = true;
    notifyListeners();

    String? statusKey;
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOffline = connectivityResult == ConnectivityResult.none;

    final prefs = await SharedPreferences.getInstance();

    if (isOffline) {
      statusKey = 'networkError';
      final cachedData = prefs.getString('search_cache');
      if (cachedData != null) {
        final List<dynamic> decoded = json.decode(cachedData);
        _searchResults = decoded.map((json) => Motorcycle.fromMap(json)).toList();
      } else {
        _searchResults = [];
      }
    } else {
      final apiKey = dotenv.env['API_NINJAS_KEY'] ?? '';
      final url = Uri.parse('https://api.api-ninjas.com/v1/motorcycles?make=$query');

      try {
        final response = await http.get(url, headers: {'X-Api-Key': apiKey});
        
        if (response.statusCode == 200) {
          await prefs.setString('search_cache', response.body);
          
          final List<dynamic> data = json.decode(response.body);
          _searchResults = data.map((json) => Motorcycle.fromMap(json)).toList();

          if (_searchResults.isEmpty) {
            statusKey = 'noResults';
          }
        } else {
          statusKey = 'apiError';
        }
      } catch (e) {
        print('Error network: $e');
        statusKey = 'networkError';
        final cachedData = prefs.getString('search_cache');
        if (cachedData != null) {
          final List<dynamic> decoded = json.decode(cachedData);
          _searchResults = decoded.map((json) => Motorcycle.fromMap(json)).toList();
        }
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
    await _db.collection('garage').add(moto.toMap());
    await loadCollection();
  }

  Future<void> removeFromCollection(Motorcycle moto) async {
    if (moto.imageFileId != null) {
      await _deletePhotoFromImageKit(moto.imageFileId!);
    }
    if (moto.id != null) {
      await _db.collection('garage').doc(moto.id).delete();
      await loadCollection();
    }
  }

  Future<void> _deletePhotoFromImageKit(String fileId) async {
    try {
      final privateKey = dotenv.env['IMAGEKIT_PRIVATE_KEY'] ?? '';
      final bytes = utf8.encode('$privateKey:'); 
      final base64Auth = base64.encode(bytes);

      final response = await http.delete(
        Uri.parse('https://api.imagekit.io/v1/files/$fileId'),
        headers: {'Authorization': 'Basic $base64Auth'},
      );

      if (response.statusCode == 204) {
        print('Success: File deleted from ImageKit');
      } else {
        print('Error ImageKit delete: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error ImageKit delete exception: $e');
    }
  }

  Future<void> attachPhoto(Motorcycle moto) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null || moto.id == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (moto.imageFileId != null) {
        await _deletePhotoFromImageKit(moto.imageFileId!);
      }

      final privateKey = dotenv.env['IMAGEKIT_PRIVATE_KEY'] ?? '';
      final bytes = utf8.encode('$privateKey:'); 
      final base64Auth = base64.encode(bytes);

      var request = http.MultipartRequest('POST', Uri.parse('https://upload.imagekit.io/api/v1/files/upload'));
      request.headers['Authorization'] = 'Basic $base64Auth';
      request.fields['fileName'] = '${moto.make}_${moto.model}.jpg';
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();
      
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        
        String uploadedUrl = jsonResponse['url'];
        String fileId = jsonResponse['fileId']; 

        await _db.collection('garage').doc(moto.id).update({
          'imageUrl': uploadedUrl,
          'imageFileId': fileId,
        });
        await loadCollection(); 
      } else {
        print('Error ImageKit upload: ${response.statusCode}');
      }
    } catch (e) {
      print('Error attachPhoto: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}