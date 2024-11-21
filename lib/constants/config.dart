// Default settings
import 'package:flutter/material.dart';

const String defaultCurrency = 'USD';

// Valid currencies with symbols
const Map<String, String> validCurrencies = {
  'USD': '\$', // Dollar
  'EUR': '€',  // Euro
  'GBP': '£',  // British Pound
  'INR': '₹',  // Indian Rupee
  'JPY': '¥',  // Japanese Yen
};

// Valid measurement units
const List<String> units = ['kWh', 'm³', 'liters', 'gallons'];
const Map<String, String> unitDescriptions = {
  'kWh': 'Kilowatt-hour',
  'm³': 'Cubic meter',
  'liters': 'Volume in liters',
  'gallons': 'Volume in gallons',
};

// List of icons
final List<IconData> meterIcons = [Icons.electric_bolt, Icons.water, Icons.fireplace, Icons.bolt];
// List of colors
final List<Color> meterColors = [Colors.red, Colors.green, Colors.blue, Colors.orange];