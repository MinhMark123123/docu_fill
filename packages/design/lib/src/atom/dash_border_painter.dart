import 'package:flutter/material.dart';

class DashBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final BorderRadius borderRadius; // Added for rounded corners

  DashBorderPainter({
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 5.0,
    this.borderRadius = BorderRadius.zero, // Default to no border radius
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    Path path;

    // Create path based on borderRadius
    if (borderRadius != BorderRadius.zero) {
      // Create a RoundedRect for the border
      path =
          Path()..addRRect(
            RRect.fromRectAndCorners(
              Rect.fromLTWH(0, 0, size.width, size.height),
              topLeft: borderRadius.topLeft,
              topRight: borderRadius.topRight,
              bottomLeft: borderRadius.bottomLeft,
              bottomRight: borderRadius.bottomRight,
            ),
          );
    } else {
      // Create a simple Rect path
      path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    // Calculate the dash pattern
    final dashPath = Path();
    double distance = 0.0;

    for (final pathMetric in path.computeMetrics()) {
      distance =
          0.0; // Reset distance for each contour (e.g., if path had holes)
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.borderRadius !=
            borderRadius; // Repaint if borderRadius changes
  }
}
