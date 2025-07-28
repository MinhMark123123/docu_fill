import 'package:docu_fill/core/core.dart';
import 'package:flutter/material.dart';

import 'view_model/setting_view_model.dart';

class SettingPage extends BaseView<SettingViewModel> {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, SettingViewModel viewModel) {
    return Center(child: Text("setting"));
  }
}
