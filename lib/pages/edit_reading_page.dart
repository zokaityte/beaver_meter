import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/reading.dart';
import '../database_helper.dart';
import '../validators/validator.dart';

class EditReadingPage extends StatefulWidget {
  final Reading reading;

  EditReadingPage({required this.reading});

  @override
  _EditReadingPageState createState() => _EditReadingPageState();
}

class _EditReadingPageState extends State<EditReadingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController readingValueController = TextEditingController();
  final TextEditingController readingDateController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    readingValueController.text = widget.reading.value.toString();
    readingDateController.text = widget.reading.date;
    selectedDate = DateTime.tryParse(widget.reading.date) ?? DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      // Update the state and text field
      setState(() {
        selectedDate = pickedDate;
        readingDateController.text = formattedDate;
      });
    }
  }

  Future<void> _saveReading(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final readingValue = readingValueController.text;
    final readingDate = readingDateController.text;

    // Perform cross-field validation
    final crossFieldError = await Validator.validateReading(
      widget.reading.meterId, // Meter ID
      readingValue, // New reading value
      readingDate, // New reading date
      originalDate: widget.reading.date, // Original reading date (optional)
    );

    if (crossFieldError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(crossFieldError)),
      );
      return;
    }

    // If validations pass, update the reading
    final updatedReading = Reading(
      id: widget.reading.id,
      meterId: widget.reading.meterId,
      value: int.parse(readingValue),
      date: readingDate,
    );

    final result = await DatabaseHelper().updateReading(updatedReading);

    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reading updated successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update reading. Please try again.')),
      );
    }
  }

  Future<void> _deleteReading() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Reading'),
        content: Text('Are you sure you want to delete this reading?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await DatabaseHelper().deleteReading(widget.reading.id!);

      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reading deleted successfully!')),
        );
        Navigator.pop(context, {'action': 'delete'});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to delete reading. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Reading'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteReading, // Call the delete method
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
                controller: readingValueController,
                decoration: InputDecoration(
                  labelText: 'Enter Reading Value',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Reading value cannot be empty';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Reading value must be a positive number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: readingDateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Date cannot be empty';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              FilledButton(
                onPressed: () => _saveReading(context),
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
