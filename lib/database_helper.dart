import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'models/meter.dart';
import 'models/price.dart';
import 'models/reading.dart';

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
        name TEXT UNIQUE,
        unit TEXT,
        color INTEGER,
        icon INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE prices(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        price_per_unit REAL,
        base_price REAL,
        valid_from TEXT,
        valid_to TEXT,
        meter_id INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(meter_id) REFERENCES meters(id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE readings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meter_id INTEGER,
        value REAL,
        date TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(meter_id) REFERENCES meters(id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE settings(
        key TEXT PRIMARY KEY,
        value TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Default currency setting
    await db.insert('settings', {
      'key': 'currency',
      'value': 'USD',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ********** CRUD Methods **********

  // Meters
  Future<int> insertMeter(Meter meter) async {
    Database db = await database;
    return await db.insert('meters', meter.toMap());
  }

  Future<List<Map<String, dynamic>>> getAllMeters() async {
    Database db = await database;
    return await db.query('meters');
  }

  Future<int> updateMeter(int id, Map<String, dynamic> meter) async {
    Database db = await database;
    return await db.update('meters', meter, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteMeter(int id) async {
    Database db = await database;
    return await db.delete('meters', where: 'id = ?', whereArgs: [id]);
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

  // Method to fetch meter name by id
  Future<String?> getMeterNameById(int meterId) async {
    Database db = await database;
    final result = await db.query(
      'meters',
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [meterId],
    );
    if (result.isNotEmpty) {
      return result.first['name'] as String;
    }
    return null; // Return null if no meter is found
  }

  // Fetch a single meter by ID
  Future<Map<String, dynamic>?> getMeterById(int meterId) async {
    final db = await database;
    final result = await db.query(
      'meters',
      where: 'id = ?',
      whereArgs: [meterId],
    );
    return result.isNotEmpty ? result.first : null;
  }

// Method to fetch all meters as Meter objects
  Future<List<Meter>> getMeters() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('meters');
    return maps.map((map) => Meter.fromMap(map)).toList();
  }


  // Prices
  Future<int> insertPrice(Price price) async {
    Database db = await database;
    return await db.insert('prices', price.toMap());
  }


  Future<List<Map<String, dynamic>>> getAllPrices() async {
    Database db = await database;
    return await db.query('prices');
  }

  Future<int> updatePrice(int id, Map<String, dynamic> price) async {
    Database db = await database;
    return await db.update('prices', price, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePrice(int id) async {
    Database db = await database;
    return await db.delete('prices', where: 'id = ?', whereArgs: [id]);
  }

  // Method to fetch prices for a specific meter ID
  Future<List<Map<String, dynamic>>> getPricesByMeterId(int meterId) async {
    Database db = await database;
    return await db.query(
      'prices',
      where: 'meter_id = ?',
      whereArgs: [meterId],
    );
  }

  // Readings
  Future<int> insertReading(Reading reading) async {
    Database db = await database;
    return await db.insert('readings', reading.toMap());
  }

  Future<List<Map<String, dynamic>>> getAllReadings() async {
    Database db = await database;
    return await db.query('readings');
  }

  Future<int> updateReading(int id, Map<String, dynamic> reading) async {
    Database db = await database;
    return await db.update('readings', reading, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteReading(int id) async {
    Database db = await database;
    return await db.delete('readings', where: 'id = ?', whereArgs: [id]);
  }

  // Settings
  Future<int> insertSetting(String key, String value) async {
    Database db = await database;
    return await db.insert('settings', {
      'key': key,
      'value': value,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getSetting(String key) async {
    Database db = await database;
    List<Map<String, dynamic>> result =
    await db.query('settings', where: 'key = ?', whereArgs: [key]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateSetting(String key, String value) async {
    Database db = await database;
    return await db.update(
      'settings',
      {
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  Future<int> deleteSetting(String key) async {
    Database db = await database;
    return await db.delete('settings', where: 'key = ?', whereArgs: [key]);
  }


}
