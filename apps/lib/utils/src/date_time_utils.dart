import 'package:docu_fill/utils/utils.dart';

class DateTimeUtils {
  DateTimeUtils._();

  /// Validator function for use with TextFormField, returning an error message string.
  static bool flexibleDateValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }
    if (value.length < 8 || value.length > 10) {
      // Quick length check (e.g. d/m/yyyy to dd/mm/yyyy)
      return false;
    }
    try {
      final dateTimeFormat = DateFormat(value);
      dateTimeFormat.format(DateTime.now());
      return true;
    } catch (e) {
      return false;
    }
  }
}
