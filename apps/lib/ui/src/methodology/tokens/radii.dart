import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Radii {
  const Radii();

  Radius radii(double value) => Radius.circular(value.w);

  Radius radiiSmall() => radii(4);

  Radius radiiMedium() => radii(8);

  Radius radiiLarge() => radii(12);

  Radius radiiExtraLarge() => radii(16);

  BorderRadius borderAll(double value) =>
      BorderRadius.all(Radius.circular(value.w));

  BorderRadius borderTopLeft(double value) =>
      BorderRadius.only(topLeft: Radius.circular(value.w));

  BorderRadius borderTopRight(double value) =>
      BorderRadius.only(topRight: Radius.circular(value.w));

  BorderRadius borderBottomLeft(double value) =>
      BorderRadius.only(bottomLeft: Radius.circular(value.w));

  BorderRadius borderBottomRight(double value) =>
      BorderRadius.only(bottomRight: Radius.circular(value.w));

  BorderRadius borderTop(double value) => BorderRadius.only(
    topLeft: Radius.circular(value.w),
    topRight: Radius.circular(value.w),
  );

  BorderRadius borderBottom(double value) => BorderRadius.only(
    bottomLeft: Radius.circular(value.w),
    bottomRight: Radius.circular(value.w),
  );

  BorderRadius borderLeft(double value) => BorderRadius.only(
    topLeft: Radius.circular(value.w),
    bottomLeft: Radius.circular(value.w),
  );

  BorderRadius borderRight(double value) => BorderRadius.only(
    topRight: Radius.circular(value.w),
    bottomRight: Radius.circular(value.w),
  );

  BorderRadius borderSmall() => borderAll(4.0);

  BorderRadius borderMedium() => borderAll(8.0);

  BorderRadius borderLarge() => borderAll(12.0);

  BorderRadius borderExtraLarge() => borderAll(16.0);
}
