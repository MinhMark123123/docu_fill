import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';

class DateInputFormat extends StatelessWidget {
  const DateInputFormat({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

/// Validates a date string that could be in 'dd/MM/yyyy' or 'MM/dd/yyyy' format.
///
/// Returns the parsed [DateTime] object if the input string is a valid date
/// in one of the specified formats.
/// Returns `null` if the input is not a valid date in either format or is malformed.
DateTime? validateFlexibleDate(String dateString) {
  if (dateString.isEmpty) {
    return null;
  }

  // Define the two possible date formats
  final List<DateFormat> possibleFormats = [
    DateFormat('MM/dd/yyyy'), // American format
    DateFormat('dd/MM/yyyy'), // European format
  ];

  DateTime? parsedDate;

  for (final format in possibleFormats) {
    try {
      // Use parseStrict to ensure the format matches exactly
      // and the date itself is valid (e.g., no Feb 30th).
      parsedDate = format.parseStrict(dateString);
      // If parsing succeeds with one format, break the loop.
      break;
    } catch (e) {
      // If parsing fails, try the next format.
      // print("Failed to parse '$dateString' with format '${format.pattern}': $e");
    }
  }

  return parsedDate; // Will be null if no format matched
}

/// Validator function for use with TextFormField, returning an error message string.
String? flexibleDateValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter a date.';
  }
  if (value.length < 8 || value.length > 10) {
    // Quick length check (e.g. d/m/yyyy to dd/mm/yyyy)
    return 'Date format is incorrect.';
  }

  final DateTime? parsedDate = validateFlexibleDate(value.trim());

  if (parsedDate == null) {
    return 'Invalid date. Use DD/MM/YYYY or MM/DD/YYYY.';
  }

  // Optional: Add range validation if needed
  // if (parsedDate.year < 1900 || parsedDate.year > 2100) {
  //   return 'Year out of valid range (1900-2100).';
  // }

  return null; // Valid
}
