import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/price.dart';
import '../database_helper.dart';

class EditPricePage extends StatefulWidget {
  final Price price;
  final String unit;

  EditPricePage({required this.price, required this.unit, Key? key}) : super(key: key);

  @override
  _EditPricePageState createState() => _EditPricePageState();
}

class _EditPricePageState extends State<EditPricePage> {
  final TextEditingController pricePerUnitController = TextEditingController();
  final TextEditingController basePriceController = TextEditingController();
  final TextEditingController validFromController = TextEditingController();
  final TextEditingController validToController = TextEditingController();

  DateTime? selectedValidFrom;
  DateTime? selectedValidTo;

  @override
  void initState() {
    super.initState();
    // Prefill controllers with existing price data
    pricePerUnitController.text = widget.price.pricePerUnit.toString();
    basePriceController.text = widget.price.basePrice.toString();
    validFromController.text = widget.price.validFrom;
    validToController.text = widget.price.validTo;

    selectedValidFrom = DateTime.tryParse(widget.price.validFrom);
    selectedValidTo = DateTime.tryParse(widget.price.validTo);
  }

  // Date picker for "Valid From"
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

  // Date picker for "Valid To"
  Future<void> _selectValidToDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedValidTo ?? DateTime.now(),
      firstDate: selectedValidFrom ?? DateTime(2000),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        selectedValidTo = pickedDate;
        validToController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  // Delete the price from the database
  Future<void> _deletePrice() async {
    final dbHelper = DatabaseHelper();
    final result = await dbHelper.deletePrice(widget.price.id!);

    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price deleted successfully!')),
      );
      Navigator.pop(context, {'action': 'delete'}); // Signal parent page to refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete price. Please try again.')),
      );
    }
  }

  // Save the updated price to the database
  Future<void> _updatePrice(BuildContext context) async {
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

    // Create an updated Price object
    final updatedPrice = Price(
      id: widget.price.id,
      meterId: widget.price.meterId,
      pricePerUnit: pricePerUnit,
      basePrice: basePrice,
      validFrom: validFrom,
      validTo: validTo,
    );

    // Update the Price in the database
    int result = await DatabaseHelper().updatePrice(updatedPrice);

    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price updated successfully!')),
      );
      Navigator.pop(context, updatedPrice);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update price. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Price'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirmDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Price'),
                  content: const Text('Are you sure you want to delete this price?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false), // Cancel
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true), // Confirm
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirmDelete == true) {
                await _deletePrice();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: pricePerUnitController,
              decoration: InputDecoration(labelText: 'Price per ${widget.unit}'),
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
                      ? null
                      : () => _selectValidToDate(context),
                ),
              ),
              readOnly: true,
              enabled: selectedValidFrom != null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _updatePrice(context),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
