import 'package:flutter/material.dart';
import 'package:beaver_meter/database_helper.dart';
import 'package:money2/money2.dart';

class SettingsProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // In-memory settings
  String _currencyCode = 'USD'; // Default currency code
  String _currencySymbol = '\$'; // Default currency symbol

  String get currencyCode => _currencyCode;
  String get currencySymbol => _currencySymbol;

  // Load settings from the database at startup
  Future<void> loadSettings() async {
    final setting = await _dbHelper.getSetting('currency');
    _currencyCode = setting?['value'] ?? 'USD'; // Default to USD if not found
    _currencySymbol = _getCurrencySymbol(_currencyCode);
    notifyListeners(); // Notify UI to update
  }

  // Update currency setting in memory and the database
  Future<void> updateCurrency(String newCurrencyCode) async {
    await _dbHelper.updateSetting('currency', newCurrencyCode);
    _currencyCode = newCurrencyCode;
    _currencySymbol = _getCurrencySymbol(newCurrencyCode);
    notifyListeners(); // Notify UI to update
  }

  // Get currency symbol using the money2 package
  String _getCurrencySymbol(String currencyCode) {
    try {
      final currency = Currencies().find(currencyCode);
      return currency?.symbol ?? ''; // Fallback to empty string if not found
    } catch (e) {
      // Handle the case where the currency code is not found
      return '';
    }
  }
}
