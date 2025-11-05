// lib/theme/custom_colors.dart
import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  // Define your custom colors as final properties
  final Color? containerBackground;
  final Color? buttonBackground;
  final Color? bodyTextColor;
  final Color? dashColor;

  // Add any other custom colors you need

  const AppColors({
    required this.buttonBackground,
    required this.containerBackground,
    required this.bodyTextColor,
    required this.dashColor,
  });

  @override
  AppColors copyWith({
    Color? buttonBackground,
    Color? containerBackground,
    Color? bodyTextColor,
    Color? dashColor,
  }) {
    return AppColors(
      containerBackground: containerBackground ?? this.containerBackground,
      buttonBackground: buttonBackground ?? this.buttonBackground,
      bodyTextColor: bodyTextColor ?? this.bodyTextColor,
      dashColor: dashColor ?? this.dashColor,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      containerBackground: Color.lerp(
        containerBackground,
        other.containerBackground,
        t,
      ),
      buttonBackground: Color.lerp(buttonBackground, other.buttonBackground, t),
      bodyTextColor: Color.lerp(bodyTextColor, other.bodyTextColor, t),
      dashColor: Color.lerp(dashColor, other.dashColor, t),
    );
  }

  // Optional: Add a static getter for convenience, though Theme.of(context).extension is preferred
  // static AppColors? of(BuildContext context) {
  //   return Theme.of(context).extension<AppColors>();
  // }

  // Optional: For easier debugging
  @override
  String toString() =>
      'AppColors('
      'containerBackground: $containerBackground, containerBackground: $containerBackground, '
      'buttonBackground: $buttonBackground, buttonBackground: $buttonBackground, '
      'bodyTextColor: $bodyTextColor, bodyTextColor: $bodyTextColor, '
      'dashColor: $dashColor, dashColor: $dashColor, '
      ')';
}
