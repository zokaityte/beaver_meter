import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:beaver_meter/database_helper.dart';
import 'package:beaver_meter/models/price.dart';

class CreatePricePage extends StatefulWidget {
  final int meterId;
  final String unit;

  const CreatePricePage({Key? key, required this.meterId, required this.unit})
      : super(key: key);

  @override
  _CreatePricePageState createState() => _CreatePricePageState();
}

class _CreatePricePageState extends State<CreatePricePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController pricePerUnitController = TextEditingController();
  final TextEditingController basePriceController = TextEditingController();
  final TextEditingController validFromController = TextEditingController();
  final TextEditingController validToController = TextEditingController();

  DateTime? selectedValidFrom;
  DateTime? selectedValidTo;

  Future<void> _selectValidFromDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedValidFrom ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        selectedValidFrom = pickedDate;
        validFromController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        validToController.clear();
        selectedValidTo = null;
      });
    }
  }

  Future<void> _selectValidToDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedValidTo ?? selectedValidFrom ?? now,
      firstDate: selectedValidFrom ?? now,
      lastDate: now.add(Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        selectedValidTo = pickedDate;
        validToController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _savePrice(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    double pricePerUnit = double.parse(pricePerUnitController.text);
    double basePrice = double.parse(basePriceController.text);
    String validFrom = validFromController.text;
    String validTo = validToController.text;

    // Check for overlapping date range
    bool isOverlapping = await DatabaseHelper().isPriceDateRangeOverlapping(
      meterId: widget.meterId,
      validFrom: validFrom,
      validTo: validTo,
    );

    if (isOverlapping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'The selected date range overlaps with an existing price.')),
      );
      return;
    }

    final price = Price(
      pricePerUnit: pricePerUnit,
      basePrice: basePrice,
      validFrom: validFrom,
      validTo: validTo,
      meterId: widget.meterId,
    );

    int result = await DatabaseHelper().insertPrice(price);

    if (result != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price created successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to create price. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Price')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: pricePerUnitController,
                decoration:
                    InputDecoration(labelText: 'Price per ${widget.unit}'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null) {
                    return 'Please enter a valid price per unit';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: basePriceController,
                decoration:
                    const InputDecoration(labelText: 'Base Price (per month)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null) {
                    return 'Please enter a valid base price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: validFromController,
                decoration: InputDecoration(
                  labelText: 'Valid From',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectValidFromDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a valid "Valid From" date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: validToController,
                decoration: InputDecoration(
                  labelText: 'Valid To',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: selectedValidFrom == null
                        ? null
                        : () => _selectValidToDate(context),
                  ),
                ),
                readOnly: true,
                enabled: selectedValidFrom != null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a valid "Valid To" date';
                  }
                  if (selectedValidTo != null &&
                      selectedValidFrom != null &&
                      selectedValidTo!.isBefore(selectedValidFrom!)) {
                    return '"Valid To" cannot be earlier than "Valid From"';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _savePrice(context),
                child: const Text('Save Price'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
