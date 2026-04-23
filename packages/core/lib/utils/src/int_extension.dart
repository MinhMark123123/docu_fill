import 'dart:math';

extension IntExtension on int {
  // Formats the integer (assumed to be bytes) into a human-readable file size string.
  ///
  /// For example:
  /// 1024 becomes "1.0 KB"
  /// 1000000 becomes "976.6 KB" (or "0.95 MB" depending on `decimals`)
  /// 1500000 becomes "1.4 MB"
  ///
  /// [decimals] specifies the number of decimal places (default is 1).
  String toHumanReadableSize({int decimals = 1}) {
    if (this <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    final i = (log(this) / log(1024)).floor(); // Or log(1000) for base 10

    // Ensure decimals is not negative
    final d = decimals < 0 ? 0 : decimals;

    // Calculate the size in the determined unit
    final sizeInUnit = this / pow(1024, i); // Or pow(1000, i)

    // Format the number with the specified number of decimals
    // and remove trailing zeros if they are all '.0' or '.00' etc.
    String formattedSize = sizeInUnit.toStringAsFixed(d);
    if (d > 0 && formattedSize.endsWith('.${'0' * d}')) {
      formattedSize = formattedSize.substring(
        0,
        formattedSize.length - (d + 1),
      );
    } else {
      // For cases like 1.50 -> 1.5 (if decimals = 2)
      // This regex removes trailing zeros after the decimal point, but keeps the point if needed.
      formattedSize = formattedSize.replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
    }

    return '$formattedSize ${suffixes[i]}';
  }
}
