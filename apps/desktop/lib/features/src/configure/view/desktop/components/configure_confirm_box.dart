import 'package:design/ui.dart';
import 'package:docu_fill/features/src/configure/view_model/configure_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class ConfigureConfirmBox extends StatelessWidget {
  const ConfigureConfirmBox({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<ConfigureViewModel>();
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
        streamData: viewModel.mode,
        builder: (context, mode) {
          switch (mode) {
            case ConfigureMode.addNew:
            case ConfigureMode.importSetting:
              return const _AddNewConfirm();
            case ConfigureMode.edit:
              return const _EditConfirm();
          }
        },
      ),
    );
  }
}

class _AddNewConfirm extends StatelessWidget {
  const _AddNewConfirm();

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<ConfigureViewModel>();
    return Row(
      children: [
        Icon(Icons.auto_awesome, color: context.colorScheme.primary),
        Dimens.spacing.horizontal(Dimens.size12),
        Text(
          AppLang.labelsDetectedFields.tr(),
          style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        const _TemplateNameInput(),
        Dimens.spacing.horizontal(Dimens.size16),
        _ImportButton(viewModel: viewModel),
        Dimens.spacing.horizontal(Dimens.size12),
        _ConfirmButton(viewModel: viewModel, onPressed: () => viewModel.confirm(context)),
      ],
    );
  }
}

class _EditConfirm extends StatelessWidget {
  const _EditConfirm();

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<ConfigureViewModel>();
    return Row(
      children: [
        Icon(Icons.edit_note, color: context.colorScheme.primary),
        Dimens.spacing.horizontal(Dimens.size12),
        Text(
          AppLang.labelsDetectedFields.tr(),
          style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        const _TemplateNameInput(showAlways: true),
        Dimens.spacing.horizontal(Dimens.size16),
        _ActionButtons(viewModel: viewModel),
      ],
    );
  }
}

class _TemplateNameInput extends StatelessWidget {
  final bool showAlways;
  const _TemplateNameInput({this.showAlways = false});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<ConfigureViewModel>();
    return SizedBox(
      width: Dimens.size300,
      child: StreamDataConsumer(
        streamData: viewModel.enableNameTemplate,
        builder: (context, data) {
          if (!data && !showAlways) return const SizedBox.shrink();
          return TextField(
            controller: viewModel.nameController,
            onChanged: (_) => viewModel.checkEnableConfirm(),
            decoration: InputDecoration(
              hintText: AppLang.messagesEnterTemplateNameHint.tr(),
              labelText: AppLang.labelsTemplateName.tr(),
              isDense: true,
            ),
          );
        },
      ),
    );
  }
}

class _ImportButton extends StatelessWidget {
  final ConfigureViewModel viewModel;
  const _ImportButton({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => viewModel.openSettingOptions(context),
      icon: const Icon(Icons.file_download_outlined, size: 18),
      label: Text(AppLang.labelsImportConfiguration.tr()),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: Dimens.radii.borderMedium()),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final ConfigureViewModel viewModel;
  final VoidCallback onPressed;
  const _ConfirmButton({required this.viewModel, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return StreamDataConsumer(
      streamData: viewModel.enableConfirm,
      builder: (context, data) {
        return ElevatedButton(
          onPressed: data ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.primary,
            foregroundColor: context.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: Dimens.radii.borderMedium()),
          ),
          child: Text(AppLang.actionsConfirm.tr()),
        );
      },
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final ConfigureViewModel viewModel;
  const _ActionButtons({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return StreamDataConsumer(
      streamData: viewModel.enableConfirm,
      builder: (context, data) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: data ? () => viewModel.saveAsCopy(context) : null,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: Dimens.radii.borderMedium()),
              ),
              child: Text(AppLang.actionsCreateCopy.tr()),
            ),
            Dimens.spacing.horizontal(Dimens.size12),
            _ConfirmButton(viewModel: viewModel, onPressed: () => viewModel.edit(context)),
          ],
        );
      },
    );
  }
}
