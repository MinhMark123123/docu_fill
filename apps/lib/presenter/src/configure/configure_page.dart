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
  final ConfigureMode? mode;
  final int? idEdit;

  const ConfigurePage({super.key, this.path, this.mode, this.idEdit});

  static Map<String, String?> paramsQuery({
    String? path,
    int? idEdit,
    required ConfigureMode mode,
  }) {
    return {
      'path': path,
      'mode': mode.valueString,
      'idEdit': idEdit.toString(),
    };
  }

  static String? queryPath({Map<String, String?>? stateQuery}) {
    if (stateQuery == null) return null;
    return stateQuery['path'];
  }

  static ConfigureMode? queryIsEditMode({Map<String, String?>? stateQuery}) {
    if (stateQuery == null) return null;
    return ConfigureMode.fromString(stateQuery['mode']);
  }

  static int? queryIdEdit({Map<String, String?>? stateQuery}) {
    if (stateQuery == null) return null;
    return int.tryParse(stateQuery['idEdit'] ?? '');
  }

  @override
  void awake(WrapperContext wrapperContext, ConfigureViewModel viewModel) {
    super.awake(wrapperContext, viewModel);
    viewModel.setupPath(
      path: path,
      mode: mode ?? ConfigureMode.addNew,
      idEdit: idEdit,
    );
  }

  @override
  Widget build(BuildContext context, viewModel) {
    return AdaptiveLayout(
      smallLayout: ConfigureMobileLayout(),
      largeLayout: ConfigureDesktopLayout(),
    );
  }
}
