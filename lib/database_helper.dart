import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
        name TEXT UNIQUE NOT NULL,
        unit TEXT NOT NULL,
        color INTEGER NOT NULL,
        icon INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP NOT NULL,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE prices(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        price_per_unit REAL NOT NULL,
        base_price REAL NOT NULL,
        valid_from TEXT NOT NULL,
        valid_to TEXT NOT NULL,
        meter_id INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP NOT NULL,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP NOT NULL,
        FOREIGN KEY(meter_id) REFERENCES meters(id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE readings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meter_id INTEGER NOT NULL,
        value INTEGER NOT NULL,
        date TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP NOT NULL,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP NOT NULL,
        FOREIGN KEY(meter_id) REFERENCES meters(id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE settings(
        key TEXT PRIMARY KEY NOT NULL,
        value TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP NOT NULL,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP NOT NULL
      )
    ''');

    // Default currency setting
    await db.insert('settings', {
      'key': 'currency',
      'value': 'USD',
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

  // Fetch a single Meter by ID
  Future<Meter?> getMeterById(int meterId) async {
    final db = await database;
    final result = await db.query(
      'meters',
      where: 'id = ?',
      whereArgs: [meterId],
    );
    return result.isNotEmpty ? Meter.fromMap(result.first) : null;
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

  Future<int> updatePrice(Price price) async {
    final db = await database;
    return await db.update(
      'prices',
      price.toMap(), // Convert Price object to Map
      where: 'id = ?',
      whereArgs: [price.id],
    );
  }

  Future<int> deletePrice(int id) async {
    Database db = await database;
    return await db.delete('prices', where: 'id = ?', whereArgs: [id]);
  }

  // Method to fetch prices for a specific meter ID
  Future<List<Price>> getPricesByMeterIdAsObjects(int meterId) async {
    final db = await database;
    final result = await db.query(
      'prices',
      where: 'meter_id = ?',
      whereArgs: [meterId],
    );

    // Convert query result to a list of Price objects
    return result.map((e) => Price.fromMap(e)).toList();
  }

  // Readings
  Future<int> insertReading(Reading reading) async {
    Database db = await database;
    return await db.insert('readings', reading.toMap());
  }

  Future<List<Reading>> getAllReadings() async {
    Database db = await database;
    final result = await db.query('readings');
    return result.map((e) => Reading.fromMap(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getReadingsWithMeterData() async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT 
      readings.id AS reading_id,
      readings.value AS reading_value,
      readings.date AS reading_date,
      meters.id AS meter_id,
      meters.name AS meter_name,
      meters.unit AS meter_unit,
      meters.color AS meter_color,  -- Include color
      meters.icon AS meter_icon    -- Include icon
    FROM readings
    INNER JOIN meters ON readings.meter_id = meters.id
    ORDER BY readings.date DESC
  ''');

    // Parse the result into a list of Reading and Meter objects
    return result.map((row) {
      return {
        'reading': Reading(
          id: row['reading_id'] as int,
          meterId: row['meter_id'] as int,
          value: row['reading_value'] as int,
          date: row['reading_date'] as String,
        ),
        'meter': Meter(
          id: row['meter_id'] as int,
          name: row['meter_name'] as String,
          unit: row['meter_unit'] as String,
          color: row['meter_color'] as int,
          // Updated key
          icon: row['meter_icon'] as int, // Updated key
        ),
      };
    }).toList();
  }

  Future<int> updateReading(Reading reading) async {
    final db = await database;
    return await db.update(
      'readings',
      reading.toMap(),
      where: 'id = ?',
      whereArgs: [reading.id],
    );
  }

  Future<int> deleteReading(int id) async {
    final db = await database;
    return await db.delete(
      'readings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String?> getLatestReadingDate(int meterId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
    SELECT date FROM readings 
    WHERE meter_id = ? 
    ORDER BY date DESC 
    LIMIT 1
    ''',
      [meterId],
    );

    if (result.isNotEmpty) {
      return result.first['date'] as String;
    }
    return null; // No readings available for this meter
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

  Future<bool> doesReadingExist(int meterId, String date) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT 1 
    FROM readings
    WHERE meter_id = ? AND date = ?
    LIMIT 1
  ''', [meterId, date]);

    return result.isNotEmpty;
  }

  Future<int?> getReadingBeforeValue(int meterId, String date) async {
    final db = await database;

    // Query to get the most recent reading value before the given date
    final result = await db.rawQuery('''
    SELECT value 
    FROM readings
    WHERE meter_id = ? AND date < ?
    ORDER BY date DESC
    LIMIT 1
  ''', [meterId, date]);

    if (result.isNotEmpty) {
      return result.first['value'] as int;
    }

    return null; // No previous reading found
  }

  Future<bool> isPriceDateRangeOverlapping({
    required int meterId,
    required String validFrom,
    required String validTo,
  }) async {
    final Database db = await database;
    final result = await db.rawQuery('''
        SELECT * FROM prices 
        WHERE meter_id = ? AND (
          (? BETWEEN valid_from AND valid_to) OR
          (? BETWEEN valid_from AND valid_to) OR
          (valid_from BETWEEN ? AND ?) OR
          (valid_from BETWEEN ? AND ?)
        )
      ''',
        [meterId, validFrom, validTo, validFrom, validTo, validFrom, validTo]);
    return result.isNotEmpty;
  }
}
