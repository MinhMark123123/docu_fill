import 'package:design/ui.dart';
import 'package:docu_fill/features/src/configure/view/desktop/components/configure_confirm_box.dart';
import 'package:docu_fill/features/src/configure/view/desktop/components/configure_header.dart';
import 'package:docu_fill/features/src/configure/view/desktop/components/configure_table_container.dart';
import 'package:flutter/material.dart';

class ConfigureDesktopLayout extends StatelessWidget {
  const ConfigureDesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.size32,
          vertical: Dimens.size24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConfigureHeader(),
            Dimens.spacing.vertical(Dimens.size32),
            ConfigureConfirmBox(),
            Dimens.spacing.vertical(Dimens.size24),
            Expanded(child: ConfigureTableContainer()),
          ],
        ),
      ),
    );
  }
}
