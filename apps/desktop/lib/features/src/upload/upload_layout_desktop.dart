import 'package:design/ui.dart';
import 'package:docu_fill/features/src/upload/components/upload_continue_button.dart';
import 'package:docu_fill/features/src/upload/components/upload_drop_box.dart';
import 'package:docu_fill/features/src/upload/components/upload_header.dart';
import 'package:docu_fill/features/src/upload/components/upload_import_label.dart';
import 'package:flutter/material.dart';

class UploadLayoutDesktop extends StatelessWidget {
  const UploadLayoutDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: Dimens.size928),
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.size24,
            vertical: Dimens.size40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UploadHeader(),
              Dimens.spacing.vertical(Dimens.size32),
              UploadDropBox(),
              Dimens.spacing.vertical(Dimens.size24),
              UploadImportLabel(),
              Dimens.spacing.vertical(Dimens.size40),
              UploadContinueButton(),
            ],
          ),
        ),
      ),
    );
  }
}
