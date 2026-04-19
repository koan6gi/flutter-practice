import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/motorcycle.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('moto_catalog.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE motorcycles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        make TEXT,
        model TEXT,
        year INTEGER,
        type TEXT,
        engine TEXT,
        power TEXT,
        transmission TEXT,
        weight TEXT
      )
    ''');
  }

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('motorcycles');
  }

  Future<int> create(Motorcycle moto) async {
    final db = await instance.database;
    return await db.insert('motorcycles', moto.toMap());
  }

  Future<List<Motorcycle>> readAll() async {
    final db = await instance.database;
    final result = await db.query('motorcycles');
    return result.map((json) => Motorcycle.fromMap(json)).toList();
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'motorcycles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}