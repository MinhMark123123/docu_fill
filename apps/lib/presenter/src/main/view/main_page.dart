import 'package:adaptive_layout/adaptive_layout.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/presenter/src/main/view/desktop/main_layout_desktop.dart';
import 'package:docu_fill/presenter/src/main/view_model/main_view_model.dart';
import 'package:flutter/material.dart';

import 'mobile/main_layout_mobile.dart';

class MainPage extends BaseView<MainViewModel> {
  final Widget child;
  const MainPage({super.key, required this.child});

  @override
  Widget build(BuildContext context, MainViewModel viewModel) {
    return AdaptiveLayout(
      smallLayout: MainLayoutMobile(child: child),
      mediumLayout: MainLayoutDesktop(child: child),
    );
  }
}
