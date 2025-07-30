import 'package:adaptive_layout/adaptive_layout.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/presenter/src/configure/view/desktop/configure_desktop_layout.dart';
import 'package:docu_fill/presenter/src/configure/view/mobile/configure_mobile_layout.dart';
import 'package:docu_fill/presenter/src/configure/view_model/configure_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class ConfigurePage extends BaseView<ConfigureViewModel> {
  final String? path;

  const ConfigurePage({super.key, this.path});

  static Map<String, String?> paramsQuery({String? path}) {
    return {'path': path};
  }

  static String? queryPath({Map<String, String?>? stateQuery}) {
    if (stateQuery == null) return null;
    return stateQuery['path'];
  }

  @override
  void awake(WrapperContext wrapperContext, ConfigureViewModel viewModel) {
    super.awake(wrapperContext, viewModel);
    viewModel.setupPath(path: path);
  }

  @override
  Widget build(BuildContext context, viewModel) {
    return AdaptiveLayout(
      smallLayout: ConfigureMobileLayout(),
      largeLayout: ConfigureDesktopLayout(),
    );
  }
}
