import 'package:docu_fill/ui/src/methodology/utils/screen_util_wrapper.dart';
import 'package:docu_fill/ui/src/theme/custom_colors.dart';
import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  ThemeData get theme => Theme.of(this);

  bool isTabletOrLarger() {
    final sizeScreen = MediaQuery.sizeOf(this);
    final bool isTabletOrLarger =
        sizeScreen.width >= ScreenUtilWrapper.tabletThresholdShortestSide;
    return isTabletOrLarger;
  }

  AppColors? get appColors => Theme.of(this).extension<AppColors>();
}
