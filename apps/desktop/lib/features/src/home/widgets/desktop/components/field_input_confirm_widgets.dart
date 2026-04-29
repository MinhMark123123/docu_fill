import 'package:design/ui.dart';
import 'package:docu_fill/features/src/home/view_model/fields_input_view_model.dart';
import 'package:docu_fill/features/src/home/widgets/desktop/components/ai_result_selector_dialog.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return Row(
      spacing: Dimens.size12,
      children: [
        Icon(Icons.history, size: 18, color: context.colorScheme.primary),
        Text(
          AppLang.labelsQuickActions.tr(),
          style: context.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Dimens.spacing.horizontal(Dimens.size8),
        _ActionButton(
          onPressed: () => viewModel.useCopy(),
          icon: Icons.content_paste_go,
          label: AppLang.actionsUseCopy.tr(),
        ),
        _ActionButton(
          onPressed: () => viewModel.createCopy(),
          icon: Icons.content_copy,
          label: AppLang.actionsCreateCopy.tr(),
        ),
        _ActionButton(
          onPressed: () async {
            final data = await showDialog<Map<String, String>>(
              context: context,
              builder: (context) => const AiResultSelectorDialog(),
            );
            if (data != null) viewModel.applyAiResult(data);
          },
          icon: Icons.psychology_outlined,
          label: AppLang.actionsImportAiResult.tr(),
          color: context.colorScheme.tertiary,
        ),
        _ActionButton(
          onPressed: () => viewModel.importFromFile(),
          icon: Icons.auto_awesome,
          label: AppLang.actionsImportData.tr(),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color? color;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: color != null ? BorderSide(color: color!.withOpacity(0.5)) : null,
        shape: RoundedRectangleBorder(
          borderRadius: Dimens.radii.borderMedium(),
        ),
      ),
    );
  }
}

class ExportSection extends StatelessWidget {
  const ExportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: Dimens.size24,
      children: [
        const Expanded(child: _ExportConfig()),
        Container(
          width: 1,
          height: Dimens.size80,
          color: context.colorScheme.outlineVariant.withOpacity(0.5),
        ),
        const _ExportButton(),
      ],
    );
  }
}

class _ExportConfig extends StatelessWidget {
  const _ExportConfig();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Dimens.size16,
      children: [_FolderPicker(), _NameInput()],
    );
  }
}

class _FolderPicker extends StatelessWidget {
  const _FolderPicker();

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return StreamDataConsumer(
      streamData: viewModel.directoryExported,
      builder: (context, data) {
        final isPicked = data.isNotEmpty;
        return InkWell(
          onTap: () => viewModel.pickFolder(),
          borderRadius: Dimens.radii.borderMedium(),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.size16,
              vertical: Dimens.size12,
            ),
            decoration: _buildDecoration(context, isPicked),
            child: _FolderPickerContent(data: data, isPicked: isPicked),
          ),
        );
      },
    );
  }

  BoxDecoration _buildDecoration(BuildContext context, bool isPicked) {
    return BoxDecoration(
      color:
          isPicked
              ? context.colorScheme.primaryContainer.withOpacity(0.3)
              : context.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      borderRadius: Dimens.radii.borderMedium(),
      border: Border.all(
        color:
            isPicked
                ? context.colorScheme.primary.withOpacity(0.5)
                : context.colorScheme.outlineVariant,
      ),
    );
  }
}

class _FolderPickerContent extends StatelessWidget {
  final String data;
  final bool isPicked;

  const _FolderPickerContent({required this.data, required this.isPicked});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isPicked ? Icons.folder : Icons.folder_open_outlined,
          size: 20,
          color:
              isPicked
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurfaceVariant,
        ),
        Dimens.spacing.horizontal(Dimens.size12),
        Expanded(
          child: Text(
            isPicked ? data : AppLang.messagesPickFolderToExport.tr(),
            style: context.textTheme.bodyMedium?.copyWith(
              color:
                  isPicked
                      ? context.colorScheme.onSurface
                      : context.colorScheme.onSurfaceVariant,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Icon(
          Icons.edit,
          size: 16,
          color: context.colorScheme.primary.withOpacity(0.5),
        ),
      ],
    );
  }
}

class _NameInput extends StatelessWidget {
  const _NameInput();

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return TextField(
      controller: viewModel.nameDocExported,
      onChanged: (_) => viewModel.checkValidate(),
      decoration: InputDecoration(
        hintText: AppLang.messagesNameTheDocumentExported.tr(),
        prefixIcon: const Icon(Icons.drive_file_rename_outline, size: 20),
        isDense: true,
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton();

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return StreamDataConsumer(
      streamData: viewModel.enableExported,
      builder: (context, data) {
        return ElevatedButton.icon(
          onPressed: data ? () => viewModel.exported() : null,
          icon: const Icon(Icons.ios_share),
          label: Text(AppLang.actionsExportData.tr()),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(Dimens.size160, Dimens.size56),
            backgroundColor: context.colorScheme.primary,
            foregroundColor: context.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: Dimens.radii.borderMedium(),
            ),
            elevation: 0,
          ),
        );
      },
    );
  }
}

class ExportSuccessMessage extends StatelessWidget {
  const ExportSuccessMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.size16,
        vertical: Dimens.size12,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: Dimens.radii.borderMedium(),
        border: Border.all(color: context.colorScheme.primary.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: context.colorScheme.primary),
          Dimens.spacing.horizontal(Dimens.size12),
          const Expanded(child: _SuccessText()),
          ElevatedButton.icon(
            onPressed: () => viewModel.resetAll(),
            icon: const Icon(Icons.add_circle_outline),
            label: Text(AppLang.labelsNewTemplate.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colorScheme.primary,
              foregroundColor: context.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessText extends StatelessWidget {
  const _SuccessText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLang.messagesDocumentExportedSuccessfully.tr(),
          style: context.textTheme.titleSmall?.copyWith(
            color: context.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          AppLang.messagesDocumentExportedReadyForDownload.tr(),
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}

class MissingKeysWarning extends StatelessWidget {
  final List<String> data;

  const MissingKeysWarning({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final content =
        data.length > 3
            ? "${data.sublist(0, 3).join(", ")}, ..."
            : data.join(", ");

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.size12,
        vertical: Dimens.size8,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: Dimens.radii.borderSmall(),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: context.colorScheme.error,
          ),
          Dimens.spacing.horizontal(Dimens.size8),
          Expanded(
            child: Text(
              "${AppLang.labelsRequired.tr()}: $content",
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
