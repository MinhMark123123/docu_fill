import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/features/src/upload/upload_layout_desktop.dart';
import 'package:docu_fill/features/src/upload/view_model/upload_view_model.dart';
import 'package:flutter/material.dart';

class UploadPage extends BaseView<UploadViewModel> {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context, UploadViewModel viewModel) {
    return const UploadLayoutDesktop();
  }
}
