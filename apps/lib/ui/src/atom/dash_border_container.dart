import 'package:docu_fill/ui/ui.dart';
import 'package:flutter/material.dart';

import 'dash_border_painter.dart';

class DashedBorderContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? borderColor;
  final double? strokeWidth;
  final double? dashWidth;
  final double? dashSpace;
  final BorderRadius borderRadius;
  final Color backgroundColor; // Added for container background

  const DashedBorderContainer({
    super.key,
    this.child,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.borderColor,
    this.strokeWidth,
    this.dashWidth,
    this.dashSpace,
    this.borderRadius = BorderRadius.zero,
    this.backgroundColor =
        Colors.transparent, // Default to transparent background
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin, // Apply margin outside the CustomPaint
      child: CustomPaint(
        painter: DashBorderPainter(
          color: borderColor ?? Colors.black,
          strokeWidth: strokeWidth ?? Dimens.size1,
          dashWidth: dashWidth ?? Dimens.size5,
          dashSpace: dashSpace ?? Dimens.size5,
          borderRadius: borderRadius,
        ),
        child: Container(
          // This inner Container is for background color and padding for the child
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius:
                borderRadius, // Match border radius for background clipping
          ),
          padding: padding,
          // Apply padding inside the border for the child
          width: double.infinity,
          // Take up available width or rely on child
          height: double.infinity,
          // Take up available height or rely on child
          child: child,
        ),
      ),
    );
  }
}
