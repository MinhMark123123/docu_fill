import 'package:adaptive_layout/adaptive_layout.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/presenter/src/home/view_model/fields_input_view_model.dart';
import 'package:docu_fill/presenter/src/home/widgets/mobile/field_input_mobile.dart';
import 'package:docu_fill/route/routers.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

import 'field_input_desktop.dart';

class InputPage extends BaseView<FieldsInputViewModel> {
  final List<int>? ids;

  const InputPage({super.key, this.ids});

  static String pathCompose(List<int>? ids) {
    final params = <String, String>{"ids": ids?.join(",") ?? ""};
    return "${RoutesPath.home}?${Uri(queryParameters: params).query}";
  }

  static List<int>? parseIds(GoRouterState state) {
    final idsString = state.uri.queryParameters['ids'];
    if (idsString == null) {
      return null;
    }
    return idsString.split(',').map((id) => int.parse(id.trim())).toList();
  }

  @override
  void awake(WrapperContext wrapperContext, FieldsInputViewModel viewModel) {
    super.awake(wrapperContext, viewModel);
    viewModel.performInit(ids);
  }

  @override
  Widget build(BuildContext context, FieldsInputViewModel viewModel) {
    return Scaffold(
      backgroundColor: context.appColors?.containerBackground,
      body: AdaptiveLayout(
        smallLayout: const FieldInputMobile(),
        mediumLayout: const FieldInputDesktop(),
      ),
    );
  }
}
