import 'package:core/const/src/app_lang.dart';
import 'package:docu_fill/features/src/configure/view/widgets/configure_table_fields.dart';
import 'package:docu_fill/features/src/configure/view_model/configure_view_model.dart';
import 'package:design/ui.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class ConfigureDesktopLayout extends StatelessWidget {
  const ConfigureDesktopLayout({super.key});

  ConfigureViewModel get configureViewModel =>
      getViewModel<ConfigureViewModel>();

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
            header(context),
            Dimens.spacing.vertical(Dimens.size32),
            confirmBox(context),
            Dimens.spacing.vertical(Dimens.size24),
            Expanded(child: configureTable(context)),
          ],
        ),
      ),
    );
  }

  Widget header(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLang.labelsConfigureTemplateFields.tr(),
          style: context.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.onSurface,
          ),
        ),
        Dimens.spacing.vertical(Dimens.size8),
        Text(
          AppLang.messagesReviewAndConfigureFields.tr(),
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget confirmBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimens.size20),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: Dimens.radii.borderLarge(),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: StreamDataConsumer(
        streamData: configureViewModel.mode,
        builder: (context, mode) {
          switch (mode) {
            case ConfigureMode.addNew:
            case ConfigureMode.importSetting:
              return addNewConfirmBox(context);
            case ConfigureMode.edit:
              return editConfirmBox(context);
          }
        },
      ),
    );
  }

  Widget addNewConfirmBox(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.auto_awesome, color: context.colorScheme.primary),
        Dimens.spacing.horizontal(Dimens.size12),
        Text(
          AppLang.labelsDetectedFields.tr(),
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: Dimens.size300,
          child: StreamDataConsumer(
            streamData: configureViewModel.enableNameTemplate,
            builder: (context, data) {
              if (!data) return const SizedBox.shrink();
              return TextField(
                controller: configureViewModel.nameController,
                onChanged: (_) => configureViewModel.checkEnableConfirm(),
                decoration: InputDecoration(
                  hintText: AppLang.messagesEnterTemplateNameHint.tr(),
                  labelText: AppLang.labelsTemplateName.tr(),
                  isDense: true,
                ),
              );
            },
          ),
        ),
        Dimens.spacing.horizontal(Dimens.size16),
        OutlinedButton.icon(
          onPressed: () => configureViewModel.openSettingOptions(context),
          icon: const Icon(Icons.file_download_outlined, size: 18),
          label: Text(AppLang.labelsImportConfiguration.tr()),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: Dimens.radii.borderMedium(),
            ),
          ),
        ),
        Dimens.spacing.horizontal(Dimens.size12),
        StreamDataConsumer(
          streamData: configureViewModel.enableConfirm,
          builder: (context, data) {
            return ElevatedButton(
              onPressed:
                  data ? () => configureViewModel.confirm(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorScheme.primary,
                foregroundColor: context.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: Dimens.radii.borderMedium(),
                ),
              ),
              child: Text(AppLang.actionsConfirm.tr()),
            );
          },
        ),
      ],
    );
  }

  Widget editConfirmBox(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.edit_note, color: context.colorScheme.primary),
        Dimens.spacing.horizontal(Dimens.size12),
        Text(
          AppLang.labelsDetectedFields.tr(),
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: Dimens.size300,
          child: TextField(
            enabled: false,
            controller: configureViewModel.nameController,
            decoration: InputDecoration(
              labelText: AppLang.labelsTemplateName.tr(),
              isDense: true,
            ),
          ),
        ),
        Dimens.spacing.horizontal(Dimens.size16),
        ElevatedButton(
          onPressed: () => configureViewModel.edit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.primary,
            foregroundColor: context.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: Dimens.radii.borderMedium(),
            ),
          ),
          child: Text(AppLang.actionsConfirm.tr()),
        ),
      ],
    );
  }

  Widget configureTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Dimens.radii.borderLarge(),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: StreamDataConsumer(
        streamData: configureViewModel.fieldsData,
        builder: (context, data) {
          return CustomScrollableTable(data: data);
        },
      ),
    );
  }
}
