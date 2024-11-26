import 'package:flutter/material.dart';
import 'package:beaver_meter/database_helper.dart';

class SettingsProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // In-memory settings
  String _currencyCode = 'USD'; // Default value

  String get currencyCode => _currencyCode;

  // Load settings from the database at startup
  Future<void> loadSettings() async {
    final setting = await _dbHelper.getSetting('currency');
    _currencyCode = setting?['value'] ?? 'USD'; // Default to USD if not found
    notifyListeners(); // Notify UI to update
  }

  // Update currency setting in memory and the database
  Future<void> updateCurrency(String newCurrencyCode) async {
    await _dbHelper.updateSetting('currency', newCurrencyCode);
    _currencyCode = newCurrencyCode;
    notifyListeners(); // Notify UI to update
  }
}
