import 'package:docu_fill/const/src/app_lang.dart';
import 'package:docu_fill/presenter/src/home/view_model/fields_input_view_model.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class FieldInputConfirmBox extends StatelessWidget {
  const FieldInputConfirmBox({super.key});

  FieldsInputViewModel get viewModel => getViewModel<FieldsInputViewModel>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimens.size24),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamDataConsumer(
            streamData: viewModel.showSummary,
            builder: (context, showSummary) {
              if (!showSummary) return _buildQuickActions(context);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: Dimens.size24,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: Dimens.size16,
                          children: [
                            _buildFolderPicker(context),
                            _buildNameInput(context),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: Dimens.size80,
                        color: context.colorScheme.outlineVariant.withOpacity(
                          0.5,
                        ),
                      ),
                      _buildExportButton(context),
                    ],
                  ),
                  StreamDataConsumer(
                    streamData: viewModel.missingKeys,
                    builder: (context, data) {
                      if (data.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: EdgeInsets.only(top: Dimens.size16),
                        child: _buildMissingKeys(context, data),
                      );
                    },
                  ),
                  Dimens.spacing.vertical(Dimens.size20),
                  _buildQuickActions(context),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
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
        OutlinedButton.icon(
          onPressed: () => viewModel.useCopy(),
          icon: const Icon(Icons.content_paste_go, size: 16),
          label: Text(AppLang.actionsUseCopy.tr()),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: Dimens.radii.borderMedium(),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => viewModel.createCopy(),
          icon: const Icon(Icons.content_copy, size: 16),
          label: Text(AppLang.actionsCreateCopy.tr()),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: Dimens.radii.borderMedium(),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => viewModel.importFromFile(),
          icon: const Icon(Icons.auto_awesome, size: 16),
          label: Text(AppLang.actionsImportData.tr()),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: Dimens.radii.borderMedium(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFolderPicker(BuildContext context) {
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
            decoration: BoxDecoration(
              color:
                  isPicked
                      ? context.colorScheme.primaryContainer.withOpacity(0.3)
                      : context.colorScheme.surfaceContainerHighest.withOpacity(
                        0.3,
                      ),
              borderRadius: Dimens.radii.borderMedium(),
              border: Border.all(
                color:
                    isPicked
                        ? context.colorScheme.primary.withOpacity(0.5)
                        : context.colorScheme.outlineVariant,
              ),
            ),
            child: Row(
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildNameInput(BuildContext context) {
    return TextField(
      controller: viewModel.nameDocExported,
      onChanged: (_) => viewModel.checkValidate(),
      decoration: InputDecoration(
        hintText: AppLang.messagesNameTheDocumentExported.tr(),
        prefixIcon: Icon(Icons.drive_file_rename_outline, size: 20),
        isDense: true,
      ),
    );
  }

  Widget _buildExportButton(BuildContext context) {
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

  Widget _buildMissingKeys(BuildContext context, List<String> data) {
    String content =
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
