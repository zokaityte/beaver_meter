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

  static Future<String?> validateReadingDate(
      int meterId, String newDate, {String? originalDate}) async {
    if (newDate.trim().isEmpty) {
      return 'Date cannot be empty';
    }

    // If the new date matches the original date, it's valid
    if (originalDate != null && newDate == originalDate) {
      return null;
    }

    // Check if the new date already exists for the given meter
    final doesExist = await DatabaseHelper().doesReadingExist(meterId, newDate);
    if (doesExist) {
      return 'There is already a reading for this meter on $newDate.';
    }

    return null; // Validation passed
  }


  static Future<String?> validateReading(
      int meterId, String? value, String newDate, {String? originalDate}) async {
    // Perform basic checks for value and newDate
    if (value == null || value.trim().isEmpty) {
      return 'Reading value cannot be empty';
    }
    if (newDate.trim().isEmpty) {
      return 'Date cannot be empty';
    }

    // Check if value is a valid positive integer
    final intValue = int.tryParse(value);
    if (intValue == null || intValue <= 0) {
      return 'Reading value must be a positive number';
    }

    // If the new date matches the original date, skip the existence check
    if (originalDate != null && newDate == originalDate) {
      // Proceed to next validations without checking for existing records
    } else {
      // Check if the new date already exists for the meter
      final doesExist = await DatabaseHelper().doesReadingExist(meterId, newDate);
      if (doesExist) {
        return 'There is already a reading for this meter on $newDate';
      }
    }

    // Check if the reading value is greater than or equal to the previous reading value
    int? readingBeforeValue = await DatabaseHelper().getReadingBeforeValue(meterId, newDate);

    if (readingBeforeValue != null) {
      int previousValue = readingBeforeValue;
      if (intValue < previousValue) {
        return 'Reading value must be greater than or equal to the previous reading value of $previousValue';
      }
    }

    return null; // Validation passed
  }

}



