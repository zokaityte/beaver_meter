import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // To format the date

class CreateReadingPage extends StatefulWidget {
  final Map<String, dynamic> meter;

  CreateReadingPage({required this.meter});

  @override
  _CreateReadingPageState createState() => _CreateReadingPageState();
}

class _CreateReadingPageState extends State<CreateReadingPage> {
  final TextEditingController readingValueController = TextEditingController();
  final TextEditingController readingDateController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Prefill the date with the current date
    readingDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Reading for ${widget.meter['name']}')),
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
                  onPressed: () => _selectDate(context),  // Open calendar
                ),
              ),
              readOnly: true,  // Make the date field read-only so user cannot manually edit
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add logic to save the reading
                Navigator.pop(context);  // Close the page after saving
              },
              child: Text('Save Reading'),
            ),
          ],
        ),
      ),
    );
  }
}
