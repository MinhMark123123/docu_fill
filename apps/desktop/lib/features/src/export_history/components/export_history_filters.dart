import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:design/ui.dart';
import 'package:docu_fill/features/src/export_history/view_model/export_history_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class ExportHistoryFilters extends StatelessWidget {
  final ExportHistoryViewModel viewModel;

  const ExportHistoryFilters({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: Dimens.radii.borderMedium(),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(Dimens.size16),
        child: StreamDataConsumer(
          streamData: viewModel.availableTemplates,
          builder: (context, availableTemplates) {
            return Row(
              spacing: Dimens.size16,
              children: [
                Expanded(
                  flex: 1,
                  child: StreamDataConsumer(
                    streamData: viewModel.searchQuery,
                    builder: (context, searchQuery) {
                      return TextFormField(
                        initialValue: searchQuery,
                        onChanged: viewModel.updateSearchQuery,
                        decoration: InputDecoration(
                          labelText: AppLang.actionsSearch.tr(),
                          hintText: AppLang.labelsSearchHistoryHint.tr(),
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: Dimens.radii.borderSmall(),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: Dimens.size12,
                            vertical: Dimens.size8,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    spacing: Dimens.size16,
                    children: [
                      Expanded(
                        child: StreamDataConsumer(
                          streamData: viewModel.selectedTemplateName,
                          builder: (context, selectedTemplate) {
                            return _TemplateDropdown(
                              selectedTemplate: selectedTemplate,
                              availableTemplates: availableTemplates,
                              onChanged: viewModel.updateSelectedTemplateName,
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: StreamDataConsumer(
                          streamData: viewModel.selectedStatus,
                          builder: (context, selectedStatus) {
                            return _StatusDropdown(
                              selectedStatus: selectedStatus,
                              onChanged: viewModel.updateSelectedStatus,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TemplateDropdown extends StatelessWidget {
  final Optional<String> selectedTemplate;
  final List<String> availableTemplates;
  final ValueChanged<Optional<String>> onChanged;

  const _TemplateDropdown({
    required this.selectedTemplate,
    required this.availableTemplates,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Optional<String>>(
      initialValue: selectedTemplate,
      onChanged: (val) => onChanged(val ?? const Optional.empty()),
      decoration: InputDecoration(
        labelText: AppLang.labelsTemplates.tr(),
        border: OutlineInputBorder(borderRadius: Dimens.radii.borderSmall()),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Dimens.size12,
          vertical: Dimens.size8,
        ),
      ),
      items: [
        DropdownMenuItem(
          value: const Optional.empty(),
          child: Text(AppLang.labelsAll.tr()),
        ),
        ...availableTemplates.map(
          (name) => DropdownMenuItem(
            value: Optional.of(name),
            child: Text(name, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final Optional<ExportHistoryStatus> selectedStatus;
  final ValueChanged<Optional<ExportHistoryStatus>> onChanged;

  const _StatusDropdown({
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Optional<ExportHistoryStatus>>(
      initialValue: selectedStatus,
      onChanged: (val) => onChanged(val ?? const Optional.empty()),
      decoration: InputDecoration(
        labelText: AppLang.labelsStatus.tr(),
        border: OutlineInputBorder(borderRadius: Dimens.radii.borderSmall()),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Dimens.size12,
          vertical: Dimens.size8,
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: Optional.empty(),
          child: _StatusLabel(AppLang.labelsAll),
        ),
        DropdownMenuItem(
          value: Optional.of(ExportHistoryStatus.success),
          child: _StatusLabel(AppLang.labelsSuccess),
        ),
        DropdownMenuItem(
          value: Optional.of(ExportHistoryStatus.partialSuccess),
          child: _StatusLabel(AppLang.labelsPartialSuccess),
        ),
        DropdownMenuItem(
          value: Optional.of(ExportHistoryStatus.failed),
          child: _StatusLabel(AppLang.labelsFailed),
        ),
      ],
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final String langKey;

  const _StatusLabel(this.langKey);

  @override
  Widget build(BuildContext context) => Text(langKey.tr());
}
