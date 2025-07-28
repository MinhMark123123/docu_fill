import 'package:docu_fill/ui/src/methodology/tokens/dimens.dart';
import 'package:flutter/material.dart';

// Optional: If you use custom fonts via google_fonts or similar
// import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Private constructor to prevent instantiation
  AppTypography._();

  // --- Font Weights ---
  // These are standard, but good to define if you want aliases or custom weights.
  static const FontWeight _bold = FontWeight.bold; // Typically w700
  static const FontWeight _medium = FontWeight.w500;
  static const FontWeight _regular = FontWeight.normal; // Typically w400

  // --- Base TextStyle (Optional but can be useful for default font family) ---
  static TextStyle get _base {
    // If using a custom font family across most styles:
    // return GoogleFonts.yourCustomFont();
    // Otherwise, it will use the default system font or what's defined in ThemeData
    return const TextStyle();
    // }

    // --- Specific Text Styles ---
  }

  /// Size: 32, Weight: Bold
  static TextStyle get displayLargeBold =>
      _base.copyWith(fontSize: Dimens.size32, fontWeight: _bold);

  /// Size: 18, Weight: Bold
  static TextStyle get headlineSmallBold =>
      _base.copyWith(fontSize: Dimens.size18, fontWeight: _bold);
  // Alternative naming: titleLargeBold, sectionTitleBold, etc.

  /// Size: 15, Weight: Medium
  static TextStyle get titleMediumMedium =>
      _base.copyWith(fontSize: Dimens.size15, fontWeight: _medium);
  // Alternative naming: subheadMedium, cardTitleMedium, etc.

  /// Size: 14, Weight: Medium
  static TextStyle get bodyMediumMedium =>
      _base.copyWith(fontSize: Dimens.size14, fontWeight: _medium);
  // Alternative naming: body1Medium, captionMedium, etc.

  /// Size: 16, Weight: Regular
  static TextStyle get bodyLargeRegular =>
      _base.copyWith(fontSize: Dimens.size16, fontWeight: _regular);
  // Alternative naming: body2Regular, contentRegular, etc.

  /// Size: 14, Weight: Regular
  static TextStyle get bodyMediumRegular =>
      _base.copyWith(fontSize: Dimens.size14, fontWeight: _regular);
  // Alternative naming: captionRegular, labelRegular, etc.

  /// Size: 14, Weight: Bold
  static TextStyle get bodyMediumBold =>
      _base.copyWith(fontSize: Dimens.size14, fontWeight: _bold);
  // Alternative naming: labelBold, buttonTextSmallBold, etc.

  // You had "14 medium" listed twice. I'll assume one might be for a different semantic purpose.
  // If they are truly identical and used for the same purpose, you only need one.
  // I'll name this one differently for clarity, assuming a different use case.
  /// Size: 14, Weight: Medium (Potentially for different context, e.g., input labels)
  static TextStyle get labelMedium =>
      _base.copyWith(fontSize: Dimens.size14, fontWeight: _medium);
  // This is identical to bodyMediumMedium. If their usage is the same,
  // just use bodyMediumMedium. If their semantic meaning is different (e.g., one for body text,
  // one for form labels), having separate names is good practice.

  // --- Helper to integrate with ThemeData's TextTheme (Optional but good practice) ---
  // This helps if you want to set these as defaults in your MaterialApp's theme.
  static TextTheme get appTextTheme {
    return TextTheme(
      // Material Design 3 type scale names. Map your custom styles to these
      // or similar standard names for better integration with Flutter widgets.
      displayLarge: displayLargeBold,
      headlineSmall: headlineSmallBold,
      titleMedium: titleMediumMedium,
      bodyLarge: bodyLargeRegular,
      bodyMedium: bodyMediumMedium,
      bodySmall: bodyMediumRegular,
      labelLarge: bodyMediumBold,
      labelMedium: labelMedium,
      // Example: buttons often use labelLarge, map your 14
      // Bold here
      // Add other mappings as needed. You might not map all your custom styles
      // directly to the standard TextTheme if they are very specific.
      // You can still use your AppTypography.yourStyle directly.
    ).apply(
      // Optional: Apply a default font family or display/body colors here if needed
      // fontFamily: GoogleFonts.lato().fontFamily,
      // bodyColor: AppColors.textPrimary,
      // displayColor: AppColors.textSecondary,
      //fontFamily: GoogleFonts.lato().fontFamily,
    );
  }
}
