import 'package:adaptive_layout/adaptive_layout.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/presenter/src/home/view_model/home_view_model.dart';
import 'package:docu_fill/presenter/src/home/widgets/desktop/home_layout_desktop.dart';
import 'package:docu_fill/presenter/src/home/widgets/mobile/home_layout_mobile.dart';
import 'package:flutter/material.dart';

class HomePage extends BaseView<HomeViewModel> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, HomeViewModel viewModel) {
    return AdaptiveLayout(
      smallLayout: HomeLayoutMobile(),
      mediumLayout: HomeLayoutDesktop(),
    );
  }
}
