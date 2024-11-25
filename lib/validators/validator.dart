import '../database_helper.dart';

class Validator {
  static String? validateNonEmpty(String? value, String fieldName) {
    if (value == null || value
        .trim()
        .isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  static String? validatePositiveInteger(String? value, String fieldName) {
    if (value == null || value
        .trim()
        .isEmpty) {
      return '$fieldName cannot be empty';
    }
    final intValue = int.tryParse(value);
    if (intValue == null || intValue <= 0) {
      return '$fieldName must be a positive integer';
    }
    return null;
  }

  static String? validateReadingValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Reading value cannot be empty';
    }
    final intValue = int.tryParse(value);
    if (intValue == null || intValue <= 0) {
      return 'Reading value must be a positive number';
    }
    return null;
  }

  static Future<String?> validateReadingDate(int meterId, String date) async {

  if (date.trim().isEmpty) {
  return 'Date cannot be empty';
  }

  // Check if the date already exists for the given meter in the database
  final doesExist = await DatabaseHelper().doesReadingExist(meterId, date);
  if (doesExist) {
  return 'There is already a reading for this meter on $date. Edit the existing reading instead.';
  }
  return null;
  }

  static Future<String?> validateReading(int meterId, String? value, String? date) async {

    // Perform basic checks for both fields
    if (value == null || value.trim().isEmpty || date == null || date.trim().isEmpty) {
      return null; // Skip cross-field validation if fields are incomplete
    }

    // Check if value is valid
    final intValue = int.tryParse(value);
    if (intValue == null || intValue <= 0) {
      return 'Reading value must be a positive number';
    }

    // Check if the date already exists in the database
    final doesExist = await DatabaseHelper().doesReadingExist(meterId, date);
    if (doesExist) {
      return 'There is already a reading for this meter on $date';
    }

    // Check if the reading value is greater than or equal to the previous reading value
    int? readingBeforeValue = await DatabaseHelper().getReadingBeforeValue(meterId, date);

    if (readingBeforeValue != null) {
      int previousValue = readingBeforeValue;
      if (intValue < previousValue) {
        return 'Reading value must be greater than or equal to the previous reading value of $previousValue';
      }
    }

    return null; // Validation passed
  }
}



