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
        'title': 'My Garage',
        'settings': 'Settings',
        'darkMode': 'Dark Mode',
        'language': 'Language',
        'delete': 'Delete',
        'make': 'Make',
        'model': 'Model',
        'year': 'Year',
        'type': 'Type',
        'engine': 'Engine',
        'power': 'Power',
        'transmission': 'Transmission',
        'weight': 'Weight',
        'searchHint': 'Enter make (e.g. Kawasaki)',
        'emptyGarage': 'Your garage is empty. Tap + to search.',
        'enterQuery': 'Please enter a make to search',
        'networkError': 'No network connection.',
        'noResults': 'No results found',
        'apiError': 'API Error',
        'searchTitle': 'Search Motorcycles',
        'addedSuccess': 'Added to Garage',
        'attachPhoto': 'Attach Photo',
        'searchGarage': 'Search in Garage',
        'allTypes': 'All types',
        'sortAsc': 'Old first',
        'sortDesc': 'New first',
        'remindMaint': 'Remind about maintenance',
        'notifyTitle': 'Maintenance Reminder!',
        'notifyBody': 'It is time to check the oil in your',
        'notifyScheduled': 'Reminder scheduled in 10s',
      },
      'ru': {
        'title': 'Мой Гараж',
        'settings': 'Настройки',
        'darkMode': 'Темная тема',
        'language': 'Язык',
        'delete': 'Удалить',
        'make': 'Марка',
        'model': 'Модель',
        'year': 'Год',
        'type': 'Класс',
        'engine': 'Двигатель',
        'power': 'Мощность',
        'transmission': 'Трансмиссия',
        'weight': 'Вес',
        'searchHint': 'Введите марку (например, Kawasaki)',
        'emptyGarage': 'Гараж пуст. Нажмите + для поиска.',
        'enterQuery': 'Введите марку для поиска',
        'networkError': 'Нет подключения к сети.',
        'noResults': 'Ничего не найдено',
        'apiError': 'Ошибка API',
        'searchTitle': 'Поиск мотоциклов',
        'addedSuccess': 'Добавлено в Гараж',
        'attachPhoto': 'Прикрепить фото',
        'searchGarage': 'Поиск по Гаражу',
        'allTypes': 'Все классы',
        'sortAsc': 'Сначала старые',
        'sortDesc': 'Сначала новые',
        'remindMaint': 'Напомнить о ТО',
        'notifyTitle': 'Время ТО!',
        'notifyBody': 'Пора проверить масло на твоем',
        'notifyScheduled': 'Уведомление придет через 10 сек',
      },
    };
    return localizedValues[_languageCode]?[key] ?? key;
  }
}