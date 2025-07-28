import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Spacing {
  const Spacing();

  Widget horizontal(double value) => SizedBox(width: value.w);

  Widget vertical(double value) => SizedBox(height: value.w);

  Widget all(double value) => SizedBox(width: value.w, height: value.w);

  Widget expanded() => const Expanded(child: SizedBox());
  Widget spacer() => const Spacer();
}
