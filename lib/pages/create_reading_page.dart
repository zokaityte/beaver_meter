import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:beaver_meter/database_helper.dart';
import 'package:beaver_meter/models/reading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../validators/validator.dart';

class CreateReadingPage extends StatefulWidget {
  final int meterId;

  CreateReadingPage({required this.meterId});

  @override
  _CreateReadingPageState createState() => _CreateReadingPageState();
}

class _CreateReadingPageState extends State<CreateReadingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController readingValueController = TextEditingController();
  final TextEditingController readingDateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String meterName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchMeterName();
    readingDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
  }

  Future<void> _fetchMeterName() async {
    String? name = await DatabaseHelper().getMeterNameById(widget.meterId);
    setState(() {
      meterName = name ?? 'Unknown Meter';
    });
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

      // Validate if the selected date already exists for the meter
      final dateError =
          await Validator.validateReadingDate(widget.meterId, formattedDate);

      if (dateError != null) {
        // Show an error message if the date already exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(dateError)),
        );
        return; // Stop further processing
      }

      // If validation passes, update the state and text field
      setState(() {
        selectedDate = pickedDate;
        readingDateController.text = formattedDate;
      });
    }
  }

  Future<void> _scanReading() async {
    final ImagePicker _picker = ImagePicker();

    try {
      // Capture image from camera
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image == null) {
        // User canceled the image capture
        return;
      }

      // Create an InputImage for ML Kit
      final InputImage inputImage = InputImage.fromFilePath(image.path);

      // Initialize the text recognizer
      final TextRecognizer textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);

      // Process the image to recognize text
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      // Extract numbers from the recognized text
      String extractedText = recognizedText.text;
      final RegExp numberRegExp = RegExp(r'\d+');
      final match = numberRegExp.firstMatch(extractedText);

      if (match != null) {
        String numberString = match.group(0)!;

        // Try parsing the numberString to an integer
        int? readingValue = int.tryParse(numberString);

        if (readingValue != null) {
          // Update the reading value controller with the integer value
          setState(() {
            readingValueController.text = readingValue.toString();
          });
        } else {
          // Parsing failed
          setState(() {
            readingValueController.text = '';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to recognize text. Please try again.')),
          );
        }
      } else {
        // No numbers found in the text
        setState(() {
          readingValueController.text = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to recognize text. Please try again.')),
        );
      }

      // Remember to close the text recognizer
      textRecognizer.close();
    } catch (e) {
      // Handle any errors during image processing
      setState(() {
        readingValueController.text = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to recognize text. Please try again.')),
      );
    }
  }

  Future<void> _saveReading(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      // Stop if individual field validations fail
      return;
    }

    final readingValue = readingValueController.text;
    final readingDate = readingDateController.text;

    // Perform cross-field validation
    final crossFieldError = await Validator.validateReading(
        widget.meterId, readingValue, readingDate);
    if (crossFieldError != null) {
      // Show a SnackBar with the cross-field validation error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(crossFieldError)),
      );
      return; // Stop saving if cross-field validation fails
    }

    // If all validations pass, proceed to save the reading
    final reading = Reading(
      meterId: widget.meterId,
      value: int.parse(readingValue),
      date: readingDate,
    );

    final result = await DatabaseHelper().insertReading(reading);

    if (result != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reading added successfully!')),
      );
      Navigator.pop(context);
    } else {
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: readingValueController,
                decoration: InputDecoration(
                  labelText: 'Enter Reading Value',
                  suffixIcon: IconButton(
                    onPressed: _scanReading,
                    icon: Icon(Icons.camera_alt),
                  ),
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
                  return null; // Validation passed
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
                  return null; // Validation passed
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _saveReading(context),
                child: Text('Save Reading'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
