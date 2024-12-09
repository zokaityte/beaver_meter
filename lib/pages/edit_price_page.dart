import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:beaver_meter/database_helper.dart';
import 'package:beaver_meter/models/price.dart';

class EditPricePage extends StatefulWidget {
  final Price price;
  final String unit;

  EditPricePage({required this.price, required this.unit, Key? key})
      : super(key: key);

  @override
  _EditPricePageState createState() => _EditPricePageState();
}

class _EditPricePageState extends State<EditPricePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController pricePerUnitController = TextEditingController();
  final TextEditingController basePriceController = TextEditingController();
  final TextEditingController validFromController = TextEditingController();
  final TextEditingController validToController = TextEditingController();

  DateTime? selectedValidFrom;
  DateTime? selectedValidTo;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    pricePerUnitController.text = widget.price.pricePerUnit.toString();
    basePriceController.text = widget.price.basePrice.toString();
    validFromController.text = widget.price.validFrom;
    validToController.text = widget.price.validTo;
    selectedValidFrom = DateTime.parse(widget.price.validFrom);
    selectedValidTo = DateTime.parse(widget.price.validTo);
  }

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
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedValidTo ?? selectedValidFrom ?? DateTime.now(),
      firstDate: selectedValidFrom ?? DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
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

    // Check for overlapping date range, excluding the current price
    bool isOverlapping = await DatabaseHelper().isPriceDateRangeOverlapping(
      meterId: widget.price.meterId,
      validFrom: validFrom,
      validTo: validTo,
      priceId: widget.price.id,
    );

    if (isOverlapping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'The selected date range overlaps with an existing price.')),
      );
      return;
    }

    final updatedPrice = Price(
      id: widget.price.id,
      pricePerUnit: pricePerUnit,
      basePrice: basePrice,
      validFrom: validFrom,
      validTo: validTo,
      meterId: widget.price.meterId,
    );

    int result = await DatabaseHelper().updatePrice(updatedPrice);

    if (result != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price updated successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to update price. Please try again.')),
      );
    }
  }

  Future<void> _deletePrice() async {
    int result = await DatabaseHelper().deletePrice(widget.price.id!);

    if (result != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price deleted successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to delete price. Please try again.')),
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
                  content:
                      const Text('Are you sure you want to delete this price?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
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
                    return 'Please enter a valid price.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: basePriceController,
                decoration:
                    const InputDecoration(labelText: 'Base Price (per month)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 24),
              FilledButton(
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
