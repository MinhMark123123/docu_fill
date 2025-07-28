import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Radii {
  const Radii();

  BorderRadius radiiAll(double value) =>
      BorderRadius.all(Radius.circular(value.w));

  BorderRadius radiiTopLeft(double value) =>
      BorderRadius.only(topLeft: Radius.circular(value.w));

  BorderRadius radiiTopRight(double value) =>
      BorderRadius.only(topRight: Radius.circular(value.w));

  BorderRadius radiiBottomLeft(double value) =>
      BorderRadius.only(bottomLeft: Radius.circular(value.w));

  BorderRadius radiiBottomRight(double value) =>
      BorderRadius.only(bottomRight: Radius.circular(value.w));

  BorderRadius radiiTop(double value) => BorderRadius.only(
    topLeft: Radius.circular(value.w),
    topRight: Radius.circular(value.w),
  );

  BorderRadius radiiBottom(double value) => BorderRadius.only(
    bottomLeft: Radius.circular(value.w),
    bottomRight: Radius.circular(value.w),
  );

  BorderRadius radiiLeft(double value) => BorderRadius.only(
    topLeft: Radius.circular(value.w),
    bottomLeft: Radius.circular(value.w),
  );

  BorderRadius radiiRight(double value) => BorderRadius.only(
    topRight: Radius.circular(value.w),
    bottomRight: Radius.circular(value.w),
  );

  BorderRadius small() => radiiAll(4.0);

  BorderRadius medium() => radiiAll(8.0);

  BorderRadius large() => radiiAll(12.0);

  BorderRadius extraLarge() => radiiAll(16.0);
}
