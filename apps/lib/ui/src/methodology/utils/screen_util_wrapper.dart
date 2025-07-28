// ui/src/core/utils/screen_util_wrapper.dart (or chosen location)
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenUtilWrapper extends StatelessWidget {
  final Widget Function(BuildContext, Widget?)? builder;

  const ScreenUtilWrapper({super.key, required this.builder});

  // Design dimensions for mobile (where scaling should apply)
  static const Size mobileDesignSize = Size(390, 844);
  static const Size tabletDesignSize = Size(1280, 800);

  // Threshold for determining if a device is a tablet (or larger)
  // This is an example, adjust based on your definition of "tablet"
  // You might use shortestSide or width.
  static const double tabletThresholdShortestSide = 600.0;
  static const double tabletThresholdWidth = 720.0; // Alternative

  @override
  Widget build(BuildContext context) {
    // final bool isTabletOrLarger = sizeScreen.shortestSide >= tabletThresholdShortestSide;
    // OR based on width:
    final bool isTabletOrLarger = context.isTabletOrLarger();
    return ScreenUtilInit(
      designSize: isTabletOrLarger ? tabletDesignSize : mobileDesignSize,
      // Always provide a design size
      minTextAdapt: true,
      // Optional: Adapt text size
      splitScreenMode: true,
      // enableScaleText: () => !isTabletOrLarger,
      // Disable text scaling on tablets
      // enableScaleWH: () => !isTabletOrLarger,
      // Disable width/height scaling on tablets
      builder: builder,
      // child: child, // The rest of your app
    );
  }
}
