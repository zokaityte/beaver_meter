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
const List<Color> meterColors = [
  Color(4283215696),
  Color(4280391411),
  Color(-7118842),
  Color(-13728548)];