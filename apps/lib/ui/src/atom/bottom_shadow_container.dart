import 'package:docu_fill/ui/ui.dart';
import 'package:flutter/material.dart';

class BottomShadowContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final Color backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color shadowColor;
  final double? shadowBlurRadius;
  final double? shadowSpreadRadius;
  final Offset? shadowOffset;

  const BottomShadowContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.backgroundColor = Colors.white,
    this.padding,
    this.margin,
    this.shadowColor = Colors.black26, // A semi-transparent black
    this.shadowBlurRadius,
    this.shadowSpreadRadius,
    this.shadowOffset, // Positive dy for bottom shadow
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: shadowBlurRadius ?? Dimens.size8,
            spreadRadius: shadowSpreadRadius ?? Dimens.size1,
            offset:
                shadowOffset ??
                Offset(0, Dimens.size4), // Key to positioning the shadow
          ),
        ],
        // Optional: if you want rounded corners for the container itself
        // borderRadius: BorderRadius.circular(12.0),
      ),
      child: child,
    );
  }
}
