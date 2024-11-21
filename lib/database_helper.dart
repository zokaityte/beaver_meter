import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE meters(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        unit TEXT,
        color INTEGER,
        icon INTEGER
      )
    ''');
  }

  Future<int> insertMeter(Map<String, dynamic> meter) async {
    Database db = await database;
    return await db.insert('meters', meter);
  }

  Future<List<Map<String, dynamic>>> getMeters() async {
    Database db = await database;
    return await db.query('meters');
  }

  Future<bool> meterNameExists(String name) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'meters',
      where: 'name = ?',
      whereArgs: [name],
    );
    return result.isNotEmpty;
  }
}