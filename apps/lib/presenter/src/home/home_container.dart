import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/presenter/src/home/view_model/home_view_model.dart';
import 'package:docu_fill/presenter/src/home/widgets/templates_collection.dart';
import 'package:flutter/material.dart';

class HomeContainer extends BaseView<HomeViewModel> {
  final Widget child;
  const HomeContainer({super.key, required this.child});
  @override
  Widget build(BuildContext context, HomeViewModel viewModel) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(flex: 1, child: TemplatesCollection()),
          Expanded(flex: 4, child: child),
        ],
      ),
    );
  }
}
