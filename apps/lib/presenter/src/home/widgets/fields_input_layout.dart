import 'package:adaptive_layout/adaptive_layout.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/presenter/src/home/view_model/fields_input_view_model.dart';
import 'package:docu_fill/presenter/src/home/view_model/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

import 'desktop/field_input_desktop.dart';
import 'mobile/field_input_mobile.dart';

class FieldsInputLayout extends BaseView<FieldsInputViewModel> {
  final List<int>? ids;

  const FieldsInputLayout({super.key, this.ids});

  @override
  void awake(WrapperContext wrapperContext, FieldsInputViewModel viewModel) {
    super.awake(wrapperContext, viewModel);
    if (ids != null) {
      viewModel.setup(ids!);
    } else {
      final sub = getViewModel<HomeViewModel>().selectedTemplateIds
          .asStream()
          .listen((data) => viewModel.setup(data));
      wrapperContext.lifeCycleManager.onDispose(() => sub.cancel());
    }
  }

  @override
  Widget build(BuildContext context, FieldsInputViewModel viewModel) {
    return AdaptiveLayout(
      smallLayout: const FieldInputMobile(),
      mediumLayout: const FieldInputDesktop(),
    );
  }
}
