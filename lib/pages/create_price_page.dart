import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:beaver_meter/database_helper.dart';

class CreatePricePage extends StatefulWidget {
  final int meterId;

  CreatePricePage({Key? key, required this.meterId}) : super(key: key);

  @override
  _CreatePricePageState createState() => _CreatePricePageState();
}

class _CreatePricePageState extends State<CreatePricePage> {
  final TextEditingController pricePerUnitController = TextEditingController();
  final TextEditingController basePriceController = TextEditingController();
  final TextEditingController validFromController = TextEditingController();
  final TextEditingController validToController = TextEditingController();

  DateTime? selectedValidFrom;
  DateTime? selectedValidTo;

  // Date picker for "Valid From"
  Future<void> _selectValidFromDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedValidFrom ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(Duration(days: 365)), // Allow up to a year in the future
    );
    if (pickedDate != null && pickedDate != selectedValidFrom) {
      setState(() {
        selectedValidFrom = pickedDate;
        validFromController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        validToController.clear(); // Clear "Valid To" if "Valid From" changes
        selectedValidTo = null;
      });
    }
  }

  // Date picker for "Valid To"
  Future<void> _selectValidToDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedValidTo ?? DateTime.now(),
      firstDate: selectedValidFrom ?? DateTime(2000), // Ensure "Valid To" is after "Valid From"
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (pickedDate != null && pickedDate != selectedValidTo) {
      setState(() {
        selectedValidTo = pickedDate;
        validToController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  // Save the price to the database
  Future<void> _savePrice(BuildContext context) async {
    double? pricePerUnit = double.tryParse(pricePerUnitController.text);
    double? basePrice = double.tryParse(basePriceController.text);
    String validFrom = validFromController.text;
    String validTo = validToController.text;

    if (pricePerUnit == null || basePrice == null || validFrom.isEmpty || validTo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields with valid values.')),
      );
      return;
    }

    if (selectedValidTo != null && selectedValidFrom != null && selectedValidTo!.isBefore(selectedValidFrom!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('"Valid To" date cannot be earlier than "Valid From" date.')),
      );
      return;
    }

    Map<String, dynamic> price = {
      'price_per_unit': pricePerUnit,
      'base_price': basePrice,
      'valid_from': validFrom,
      'valid_to': validTo,
      'meter_id': widget.meterId,
    };

    int result = await DatabaseHelper().insertPrice(price);

    if (result != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price created successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create price. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Price')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: pricePerUnitController,
              decoration: const InputDecoration(labelText: 'Price per Unit'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: basePriceController,
              decoration: const InputDecoration(labelText: 'Base Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: validFromController,
              decoration: InputDecoration(
                labelText: 'Valid From',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectValidFromDate(context),
                ),
              ),
              readOnly: true,
            ),
            TextField(
              controller: validToController,
              decoration: InputDecoration(
                labelText: 'Valid To',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: selectedValidFrom == null
                      ? null // Disable button if "Valid From" is not selected
                      : () => _selectValidToDate(context),
                ),
              ),
              readOnly: true,
              enabled: selectedValidFrom != null, // Disable field if "Valid From" is not set
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _savePrice(context),
              child: const Text('Save Price'),
            ),
          ],
        ),
      ),
    );
  }
}
