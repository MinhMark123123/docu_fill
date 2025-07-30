import 'package:adaptive_layout/adaptive_layout.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/presenter/src/upload/view/desktop/upload_layout_desktop.dart';
import 'package:docu_fill/presenter/src/upload/view/mobile/upload_layout_mobile.dart';
import 'package:docu_fill/presenter/src/upload/view_model/upload_view_model.dart';
import 'package:flutter/material.dart';

class UploadPage extends BaseView<UploadViewModel> {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context, UploadViewModel viewModel) {
    return AdaptiveLayout(
      smallLayout: UploadLayoutMobile(),
      mediumLayout: UploadLayoutDesktop(),
    );
  }
}
