import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../data/models/motorcycle.dart';

class MotoProvider with ChangeNotifier {
  List<Motorcycle> _collection = [];
  List<Motorcycle> _searchResults = [];
  bool _isLoading = false;

  String _searchQuery = '';
  String _selectedType = 'All';
  bool _sortAscending = false;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  StreamSubscription? _subscription;
  User? _user;

  MotoProvider() {
    _initNotifications();
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _setupRealtimeListener();
      notifyListeners();
    });
  }

  Future<void> _initNotifications() async {
    tz.initializeTimeZones(); 

    const AndroidInitializationSettings initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: initSettingsAndroid);
    
    await _notificationsPlugin.initialize(
      settings: initSettings,
    );

    _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  List<Motorcycle> get collection => _collection;
  List<Motorcycle> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get selectedType => _selectedType;
  bool get sortAscending => _sortAscending;

  List<String> get availableTypes {
    final types = _collection.map((m) => m.type).toSet().toList();
    types.insert(0, 'All');
    return types;
  }

  List<Motorcycle> get filteredCollection {
    List<Motorcycle> result = List.from(_collection);

    if (_selectedType != 'All') {
      result = result.where((m) => m.type == _selectedType).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final indexedList = result.asMap().entries.map((e) => '${e.key}:::${e.value.make} ${e.value.model}').toList();
      
      final fuzzy = Fuzzy(
        indexedList,
        options: FuzzyOptions(threshold: 0.4),
      );
      
      final fuzzyResults = fuzzy.search(_searchQuery.trim());
      
      result = fuzzyResults.map((r) {
        final indexStr = r.item.toString().split(':::')[0];
        final index = int.parse(indexStr);
        return result[index];
      }).toList();
    }

    result.sort((a, b) {
      if (_sortAscending) {
        return a.year.compareTo(b.year);
      } else {
        return b.year.compareTo(a.year);
      }
    });

    return result;
  }

  void _setupRealtimeListener() {
    _subscription?.cancel();
    if (_user == null) {
      _collection = [];
      notifyListeners();
      return;
    }

    _subscription = _db
        .collection('garage')
        .where('ownerId', isEqualTo: _user!.uid)
        .snapshots()
        .listen((snapshot) {
      _collection = snapshot.docs.map((doc) {
        return Motorcycle.fromMap(doc.data(), docId: doc.id);
      }).toList();
      notifyListeners();
    });
  }

  Future<void> authAction(String email, String password, bool isLogin) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
      } else {
        await _auth.createUserWithEmailAndPassword(email: email, password: password);
      }
    } catch (e) {
      debugPrint('Auth Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void signOut() {
    _auth.signOut();
  }

  void setGarageSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void toggleSort() {
    _sortAscending = !_sortAscending;
    notifyListeners();
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
        debugPrint('Error network: $e');
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
    if (_user == null) return;
    final data = moto.toMap();
    data['ownerId'] = _user!.uid;
    await _db.collection('garage').add(data);
  }

  Future<void> removeFromCollection(Motorcycle moto) async {
    if (moto.imageFileId != null) {
      await _deletePhotoFromImageKit(moto.imageFileId!);
    }
    if (moto.id != null) {
      await _db.collection('garage').doc(moto.id).delete();
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
        debugPrint('Success: File deleted from ImageKit');
      } else {
        debugPrint('Error ImageKit delete: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error ImageKit delete exception: $e');
    }
  }

  Future<void> attachPhoto(Motorcycle moto, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    
    if (image == null || moto.id == null) return;

    _isLoading = true;
    notifyListeners();

    try {
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
        
        String newUploadedUrl = jsonResponse['url'];
        String newFileId = jsonResponse['fileId']; 

        final doc = await _db.collection('garage').doc(moto.id).get();
        final oldFileId = doc.data()?['imageFileId'];

        await _db.collection('garage').doc(moto.id).update({
          'imageUrl': newUploadedUrl,
          'imageFileId': newFileId,
        });

        if (oldFileId != null) {
          await _deletePhotoFromImageKit(oldFileId);
        }
      } else {
        debugPrint('Error ImageKit upload: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error attachPhoto: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> scheduleReminder(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'moto_maintenance_channel', 
      'Maintenance Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id: 0,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}