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
final List<IconData> meterIcons = [
  Icons.electric_bolt,      // Electricity
  Icons.water,              // Water
  Icons.fireplace,          // Gas
  Icons.lightbulb,          // Light/Electricity
  Icons.energy_savings_leaf,// Eco-friendly/Energy Savings
  Icons.shower,             // Water/Usage in Showers
  Icons.battery_charging_full, // Battery Meter/Power
  Icons.solar_power,        // Solar Energy
  Icons.water_drop,         // Water Drop Icon
  Icons.device_thermostat,  // Temperature Control
];

// List of colors
const Map<int, Color> meterColorsMap = {
  1: Color(0xFF20638C), // Background-1
  2: Color(0xFFF2B705), // Background-2
  3: Color(0xFFA68A37), // Background-3
  4: Color(0xFFD96704), // Background-4
  5: Color(0xFF8C4A32), // Background-5
};