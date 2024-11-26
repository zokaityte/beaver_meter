import 'package:flutter/material.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:beaver_meter/database_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _currencyCode = 'USD'; // Default currency code
  String _currencySymbol = '\$'; // Default currency symbol

  @override
  void initState() {
    super.initState();
    _loadCurrencySetting();
  }

  Future<void> _loadCurrencySetting() async {
    final setting = await _dbHelper.getSetting('currency');
    setState(() {
      _currencyCode = setting?['value'] ?? 'USD'; // Default to USD if not found
      _currencySymbol = _getCurrencySymbol(_currencyCode);
    });
  }

  Future<void> _updateCurrencySetting(
      String newCurrencyCode, String newCurrencySymbol) async {
    await _dbHelper.updateSetting('currency', newCurrencyCode);
    setState(() {
      _currencyCode = newCurrencyCode;
      _currencySymbol = newCurrencySymbol;
    });
  }

  String _getCurrencySymbol(String currencyCode) {
    // Use a fallback map for commonly used currencies if currency_picker doesn't provide symbols
    const currencySymbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'INR': '₹',
      'JPY': '¥',
    };
    return currencySymbols[currencyCode] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // Currency setting
          ListTile(
            title: const Text('Currency'),
            subtitle: Text('$_currencyCode ($_currencySymbol)'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showCurrencyPicker(
                  context: context,
                  showFlag: true,
                  showCurrencyName: true,
                  showCurrencyCode: true,
                  onSelect: (Currency currency) {
                    _updateCurrencySetting(currency.code, currency.symbol);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
