import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:beaver_meter/database_helper.dart';
import 'package:beaver_meter/models/reading.dart';

class CreateReadingPage extends StatefulWidget {
  final int meterId;

  CreateReadingPage({required this.meterId});

  @override
  _CreateReadingPageState createState() => _CreateReadingPageState();
}

class _CreateReadingPageState extends State<CreateReadingPage> {
  final TextEditingController readingValueController = TextEditingController();
  final TextEditingController readingDateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String meterName = 'Loading...'; // Placeholder for the meter name

  @override
  void initState() {
    super.initState();
    _fetchMeterName(); // Fetch the meter name on initialization
    readingDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
  }

  // Fetch the meter name using the meterId
  Future<void> _fetchMeterName() async {
    String? name = await DatabaseHelper().getMeterNameById(widget.meterId);
    setState(() {
      meterName = name ?? 'Unknown Meter';
    });
  }

  // Method to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        readingDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  // Method to save the reading
  Future<void> _saveReading(BuildContext context) async {
    double? readingValue = double.tryParse(readingValueController.text);
    String readingDate = readingDateController.text;

    if (readingValue == null || readingDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid reading value and date.')),
      );
      return;
    }

    // Create a Reading object
    final reading = Reading(
      meterId: widget.meterId,
      value: readingValue,
      date: readingDate,
    );

    // Insert into the database
    int result = await DatabaseHelper().insertReading(reading);

    if (result != -1) {
      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reading added successfully!')),
      );
      Navigator.pop(context);
    } else {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add reading. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Reading for $meterName')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: readingValueController,
              decoration: InputDecoration(
                labelText: 'Enter Reading Value',
                suffixIcon: IconButton(
                  onPressed: () {
                    // Placeholder for OCR image selection
                  },
                  icon: Icon(Icons.camera_alt),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextField(
              controller: readingDateController,
              decoration: InputDecoration(
                labelText: 'Date',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context), // Open calendar
                ),
              ),
              readOnly: true, // Make the date field read-only so user cannot manually edit
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveReading(context),
              child: Text('Save Reading'),
            ),
          ],
        ),
      ),
    );
  }
}
