import 'package:docu_fill/ui/src/methodology/tokens/colors.dart';
import 'package:docu_fill/ui/src/methodology/tokens/dimens.dart';
import 'package:docu_fill/ui/src/methodology/tokens/typography.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'custom_colors.dart';

class AppTheme {
  AppTheme._(); // Private constructor

  // --- LIGHT THEME (Predefined) ---
  static ThemeData get lightTheme {
    final textThemeLight = _buildTextTheme(
      AppTypography.appTextTheme,
      Colors.black87,
      Colors.black54,
    );
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.white, // Your predefined light theme seed color
      brightness: Brightness.light,
    );
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      // You can still customize textTheme, buttonTheme etc. if the generated
      // defaults from ColorScheme.fromSeed aren't exactly what you want.
      textTheme: textThemeLight,
      elevatedButtonTheme: _buildElevatedButtonTheme(
        colorScheme.primary,
        Colors.white,
        textThemeLight,
      ),
      filledButtonTheme: _buildFillButtonTheme(
        AppColorsDefine.buttonBackground.light,
        Colors.white,
        textThemeLight,
      ),
      appBarTheme: _buildAppBarTheme(Colors.blue[700]!, Colors.white),
      cardTheme: _buildCardTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(
        Colors.grey[400]!,
        Colors.blue[700]!,
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppColors(
          buttonBackground: AppColorsDefine.buttonBackground.light,
          bodyTextColor: AppColorsDefine.bodyTextColor.light,
          dashColor: AppColorsDefine.dashColor.light,
        ),
        // Add other ThemeExtensions if you have them
      ],
      useMaterial3: true,
    );
  }

  // --- DARK THEME (Predefined) ---
  static ThemeData get darkTheme {
    final textThemeDark = _buildTextTheme(
      AppTypography.appTextTheme,
      Colors.white,
      Colors.white70,
    );
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blueAccent, // Your predefined dark theme seed color
      brightness: Brightness.dark,
    );
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textThemeDark,
      elevatedButtonTheme: _buildElevatedButtonTheme(
        colorScheme.primary,
        Colors.black87,
        textThemeDark,
      ),
      filledButtonTheme: _buildFillButtonTheme(
        AppColorsDefine.buttonBackground.light,
        Colors.black87,
        textThemeDark,
      ),
      appBarTheme: _buildAppBarTheme(Colors.grey[900]!, Colors.white),
      cardTheme: _buildCardTheme(cardColor: Colors.grey[800]),
      inputDecorationTheme: _buildInputDecorationTheme(
        Colors.grey[700]!,
        Colors.blue[300]!,
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppColors(
          buttonBackground: AppColorsDefine.buttonBackground.dark,
          bodyTextColor: AppColorsDefine.bodyTextColor.dark,
          dashColor: AppColorsDefine.dashColor.dark,
        ),
        // Add other ThemeExtensions if you have them
      ],
      useMaterial3: true,
    );
  }

  // --- DYNAMIC CUSTOM THEME FUNCTION ---
  static ThemeData getCustomThemeFromColor({
    required Color seedColor,
    required Brightness
    brightness, // Allow specifying if the custom theme should be light or dark based
  }) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    // Determine text colors based on brightness
    final Color primaryTextColor =
        brightness == Brightness.light ? Colors.black87 : Colors.white;
    final Color secondaryTextColor =
        brightness == Brightness.light ? Colors.black54 : Colors.white70;

    // Determine button colors based on brightness and primary color contrast
    // For buttons, we typically want good contrast with the button's background (colorScheme.primary)
    final Color buttonForegroundColor =
        ThemeData.estimateBrightnessForColor(colorScheme.primary) ==
                Brightness.dark
            ? Colors.white
            : Colors.black;
    final textTheme = _customTextTheme(
      brightness,
      primaryTextColor,
      secondaryTextColor,
    );
    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      // Often derived from colorScheme
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      elevatedButtonTheme: _buildElevatedButtonTheme(
        colorScheme.primary,
        buttonForegroundColor,
        textTheme,
      ),
      appBarTheme: _buildAppBarTheme(
        colorScheme.brightness == Brightness.dark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.primary,
        // Use surface for dark AppBars if primary is too light
        colorScheme
            .onPrimary, // Or colorScheme.onSurface for the dark appbar case
      ),
      cardTheme: _buildCardTheme(
        cardColor: colorScheme.surfaceContainerHighest,
      ),
      inputDecorationTheme: _buildInputDecorationTheme(
        colorScheme.outline,
        colorScheme.primary,
      ),
      useMaterial3: true,
      // You can add more specific component theming here that might depend on the colorScheme
      // For example, FloatingActionButton:
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      // Chip theme example
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.secondaryContainer,
        labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
        secondarySelectedColor: colorScheme.primary,
        selectedColor: colorScheme.primary,
        checkmarkColor: colorScheme.onPrimary,
      ),
      // Add other component themes as needed
    );
  }

  static TextTheme _customTextTheme(
    Brightness brightness,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return _buildTextTheme(
      brightness == Brightness.light
          ? ThemeData.light().textTheme
          : ThemeData.dark().textTheme,
      primaryTextColor,
      secondaryTextColor,
    );
  }

  // --- HELPER METHODS FOR THEME COMPONENTS (to reduce repetition) ---
  // These helpers can be used by both predefined and custom themes.

  static TextTheme _buildTextTheme(
    TextTheme base,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(color: primaryTextColor),
      displayMedium: base.displayMedium?.copyWith(color: primaryTextColor),
      headlineSmall: base.headlineSmall?.copyWith(color: primaryTextColor),
      titleLarge: base.titleLarge?.copyWith(color: primaryTextColor),
      bodyLarge: base.bodyLarge?.copyWith(color: primaryTextColor),
      bodyMedium: base.bodyMedium?.copyWith(color: secondaryTextColor),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ), // Used by buttons, color is set in button theme
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(
    Color backgroundColor,
    Color foregroundColor,
    TextTheme textTheme,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.size20,
          vertical: Dimens.size14,
        ),
        textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: Dimens.radii.borderSmall()),
      ),
    );
  }

  static FilledButtonThemeData _buildFillButtonTheme(
    Color backgroundColor,
    Color foregroundColor,
    TextTheme textTheme,
  ) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.size16,
          vertical: Dimens.size6,
        ),
        textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: Dimens.radii.borderSmall()),
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme(
    Color backgroundColor,
    Color foregroundColor,
  ) {
    return AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      // Common for M3 style
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: Dimens.size20,
        fontWeight: FontWeight.w600,
        color: foregroundColor,
      ),
      iconTheme: IconThemeData(color: foregroundColor),
    );
  }

  static CardThemeData _buildCardTheme({Color? cardColor}) {
    // cardColor is optional for light theme
    return CardThemeData(
      elevation: 1.0, // Subtle elevation for M3
      color: cardColor, // If null, defaults will be used based on ColorScheme
      margin: EdgeInsets.symmetric(
        horizontal: Dimens.size8,
        vertical: Dimens.size4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: Dimens.radii.borderLarge(), // M3 often uses
        // larger
        // radii
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(
    Color borderColor,
    Color focusedBorderColor,
  ) {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: Dimens.radii.borderMedium(),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        // Explicitly define for enabled state
        borderRadius: Dimens.radii.borderMedium(),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: Dimens.radii.borderMedium(),
        borderSide: BorderSide(color: focusedBorderColor, width: Dimens.size2),
      ),
    );
  }
}
