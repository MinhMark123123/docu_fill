import 'package:docu_fill/ui/src/methodology/tokens/radii.dart';
import 'package:docu_fill/ui/src/methodology/tokens/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Dimens {
  Dimens._(); // Private constructor to prevent instantiation
  static const Spacing spacing = Spacing();
  static const Radii radii = Radii();

  static double get size1 => 1.w;

  static double get size2 => 2.w;

  static double get size3 => 3.w;

  static double get size4 => 4.w;

  static double get size5 => 5.w;

  static double get size6 => 6.w;

  static double get size7 => 7.w;

  static double get size8 => 8.w;

  static double get size9 => 9.w;

  static double get size10 => 10.w;

  static double get size11 => 11.w;

  static double get size12 => 12.w;

  static double get size13 => 13.w;

  static double get size14 => 14.w;

  static double get size15 => 15.w;

  static double get size16 => 16.w;

  static double get size17 => 17.w;

  static double get size18 => 18.w;

  static double get size19 => 19.w;

  static double get size20 => 20.w;

  static double get size21 => 21.w;

  static double get size22 => 22.w;

  static double get size23 => 23.w;

  static double get size24 => 24.w;

  static double get size25 => 25.w;

  static double get size26 => 26.w;

  static double get size27 => 27.w;

  static double get size28 => 28.w;

  static double get size29 => 29.w;

  static double get size30 => 30.w;

  static double get size31 => 31.w;

  static double get size32 => 32.w;

  static double get size33 => 33.w;

  static double get size34 => 34.w;

  static double get size35 => 35.w;

  static double get size36 => 36.w;

  static double get size37 => 37.w;

  static double get size38 => 38.w;

  static double get size39 => 39.w;

  static double get size40 => 40.w;

  static double get size41 => 41.w;

  static double get size42 => 42.w;

  static double get size43 => 43.w;

  static double get size44 => 44.w;

  static double get size45 => 45.w;

  static double get size46 => 46.w;

  static double get size47 => 47.w;

  static double get size48 => 48.w;

  static double get size49 => 49.w;

  static double get size50 => 50.w;

  static double get size51 => 51.w;

  static double get size52 => 52.w;

  static double get size53 => 53.w;

  static double get size54 => 54.w;

  static double get size55 => 55.w;

  static double get size56 => 56.w;

  static double get size57 => 57.w;

  static double get size58 => 58.w;

  static double get size59 => 59.w;

  static double get size60 => 60.w;

  static double get size61 => 61.w;

  static double get size62 => 62.w;

  static double get size63 => 63.w;

  static double get size64 => 64.w;

  static double get size65 => 65.w;

  static double get size66 => 66.w;

  static double get size67 => 67.w;

  static double get size68 => 68.w;

  static double get size69 => 69.w;

  static double get size70 => 70.w;

  static double get size71 => 71.w;

  static double get size72 => 72.w;

  static double get size73 => 73.w;

  static double get size74 => 74.w;

  static double get size75 => 75.w;

  static double get size76 => 76.w;

  static double get size77 => 77.w;

  static double get size78 => 78.w;

  static double get size79 => 79.w;

  static double get size80 => 80.w;

  static double get size81 => 81.w;

  static double get size82 => 82.w;

  static double get size83 => 83.w;

  static double get size84 => 84.w;

  static double get size85 => 85.w;

  static double get size86 => 86.w;

  static double get size87 => 87.w;

  static double get size88 => 88.w;

  static double get size89 => 89.w;

  static double get size90 => 90.w;

  static double get size91 => 91.w;

  static double get size92 => 92.w;

  static double get size93 => 93.w;

  static double get size94 => 94.w;

  static double get size95 => 95.w;

  static double get size96 => 96.w;

  static double get size97 => 97.w;

  static double get size98 => 98.w;

  static double get size99 => 99.w;

  static double get size100 => 100.w;

  static double get size120 => 120.w;

  static double get size150 => 150.w;

  static double get size160 => 160.w;

  static double get size170 => 170.w;

  static double get size180 => 180.w;

  static double get size200 => 200.w;

  static double get size400 => 400.w;

  static double get size928 => 928.w;

  static double get size232 => 232.w;

  // Add more dimensions as needed
}

extension SizeExtension on double {
  Widget wBox() => SizedBox(width: this);

  Widget hBox() => SizedBox(height: this);

  EdgeInsets tPadding() => EdgeInsets.only(top: this);

  EdgeInsets rPadding() => EdgeInsets.only(right: this);

  EdgeInsets bPadding() => EdgeInsets.only(bottom: this);

  EdgeInsets lPadding() => EdgeInsets.only(left: this);

  EdgeInsets hPadding() => EdgeInsets.symmetric(horizontal: this);

  EdgeInsets vPadding() => EdgeInsets.symmetric(vertical: this);

  EdgeInsets paddingAll() => EdgeInsets.all(this);

  EdgeInsets paddingSymmetric() {
    return EdgeInsets.symmetric(horizontal: this, vertical: this);
  }
}
