import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _languageCode = 'ru'; 

  bool get isDarkMode => _isDarkMode;
  String get languageCode => _languageCode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _languageCode = prefs.getString('languageCode') ?? 'ru';
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> changeLanguage(String code) async {
    _languageCode = code;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('languageCode', code);
    notifyListeners();
  }

  String translate(String key) {
    Map<String, Map<String, String>> localizedValues = {
      'en': {
        'title': 'Moto Catalog',
        'settings': 'Settings',
        'darkMode': 'Dark Mode',
        'language': 'Language',
        'add': 'Add Motorcycle',
        'delete': 'Delete',
        'brand': 'Brand',
        'model': 'Model',
        'year': 'Year',
        'desc': 'Description',
        'save': 'Save',
      },
      'ru': {
        'title': 'Каталог Мотоциклов',
        'settings': 'Настройки',
        'darkMode': 'Темная тема',
        'language': 'Язык',
        'add': 'Добавить мотоцикл',
        'delete': 'Удалить',
        'brand': 'Марка',
        'model': 'Модель',
        'year': 'Год',
        'desc': 'Описание',
        'save': 'Сохранить',
      },
    };
    return localizedValues[_languageCode]?[key] ?? key;
  }
}
