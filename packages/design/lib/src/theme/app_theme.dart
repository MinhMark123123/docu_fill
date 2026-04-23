import 'package:design/src/methodology/tokens/colors.dart';
import 'package:design/src/methodology/tokens/dimens.dart';
import 'package:design/src/methodology/tokens/typography.dart';
import 'package:flutter/material.dart';

import 'custom_colors.dart';

class AppTheme {
  AppTheme._(); // Private constructor

  // --- LIGHT THEME ---
  static ThemeData get lightTheme {
    final textThemeLight = _buildTextTheme(
      AppTypography.appTextTheme,
      AppColorsDefine.bodyTextColor.light.withOpacity(0.9),
      AppColorsDefine.bodyTextColor.light,
    );
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColorsDefine.primaryIndigo,
      brightness: Brightness.light,
      surface: AppColorsDefine.containerBackground.light,
    );
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textThemeLight,
      elevatedButtonTheme: _buildElevatedButtonTheme(
        colorScheme.primary,
        Colors.white,
        textThemeLight,
      ),
      filledButtonTheme: _buildFillButtonTheme(
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        textThemeLight,
      ),
      appBarTheme: _buildAppBarTheme(
        colorScheme.surface,
        colorScheme.onSurface,
      ),
      cardTheme: _buildCardTheme(cardColor: Colors.white),
      inputDecorationTheme: _buildInputDecorationTheme(
        colorScheme.outlineVariant,
        colorScheme.primary,
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppColors(
          containerBackground: AppColorsDefine.containerBackground.light,
          buttonBackground: AppColorsDefine.buttonBackground.light,
          bodyTextColor: AppColorsDefine.bodyTextColor.light,
          dashColor: AppColorsDefine.dashColor.light,
        ),
      ],
      useMaterial3: true,
    );
  }

  // --- DARK THEME ---
  static ThemeData get darkTheme {
    final textThemeDark = _buildTextTheme(
      AppTypography.appTextTheme,
      Colors.white.withOpacity(0.95),
      AppColorsDefine.bodyTextColor.dark,
    );
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColorsDefine.primaryIndigo,
      brightness: Brightness.dark,
      surface: AppColorsDefine.containerBackground.dark,
    );
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textThemeDark,
      elevatedButtonTheme: _buildElevatedButtonTheme(
        colorScheme.primary,
        colorScheme.onPrimary,
        textThemeDark,
      ),
      filledButtonTheme: _buildFillButtonTheme(
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        textThemeDark,
      ),
      appBarTheme: _buildAppBarTheme(
        colorScheme.surface,
        colorScheme.onSurface,
      ),
      cardTheme: _buildCardTheme(cardColor: colorScheme.surface),
      inputDecorationTheme: _buildInputDecorationTheme(
        colorScheme.outlineVariant,
        colorScheme.primary,
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppColors(
          containerBackground: AppColorsDefine.containerBackground.dark,
          buttonBackground: AppColorsDefine.buttonBackground.dark,
          bodyTextColor: AppColorsDefine.bodyTextColor.dark,
          dashColor: AppColorsDefine.dashColor.dark,
        ),
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
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: foregroundColor, size: Dimens.size24),
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
