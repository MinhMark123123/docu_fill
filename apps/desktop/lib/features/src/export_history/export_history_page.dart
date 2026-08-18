import 'package:design/ui.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/features/src/export_history/components/export_history_detail_pane.dart';
import 'package:docu_fill/features/src/export_history/components/export_history_filters.dart';
import 'package:docu_fill/features/src/export_history/components/export_history_list_item.dart';
import 'package:docu_fill/features/src/export_history/view_model/export_history_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class ExportHistoryPage extends BaseView<ExportHistoryViewModel> {
  const ExportHistoryPage({super.key});

  @override
  Widget build(BuildContext context, ExportHistoryViewModel viewModel) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLang.labelsExportHistory.tr()),
        backgroundColor: context.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.size24,
          vertical: Dimens.size8,
        ),
        child: Column(
          children: [
            ExportHistoryFilters(viewModel: viewModel),
            Dimens.spacing.vertical(Dimens.size16),
            Expanded(
              child: StreamDataConsumer(
                streamData: viewModel.filteredHistories,
                builder: (context, filteredHistories) {
                  return StreamDataConsumer(
                    streamData: viewModel.selectedHistory,
                    builder: (context, selectedHistoryOpt) {
                      final selectedHistory = selectedHistoryOpt.value;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: filteredHistories.isEmpty
                                ? const _EmptyHistoryPlaceholder()
                                : ListView.builder(
                                    itemCount: filteredHistories.length,
                                    itemBuilder: (context, index) {
                                      final item = filteredHistories[index];
                                      return ExportHistoryListItem(
                                        history: item,
                                        isSelected:
                                            selectedHistory?.id == item.id,
                                        onTap: () =>
                                            viewModel.selectHistory(item),
                                      );
                                    },
                                  ),
                          ),
                          if (selectedHistory != null) ...[
                            Dimens.spacing.horizontal(Dimens.size16),
                            Expanded(
                              flex: 4,
                              child: ExportHistoryDetailPane(
                                history: selectedHistory,
                                onReExport: () =>
                                    viewModel.reExport(selectedHistory),
                                onRestore: () => viewModel.restoreToForm(
                                  context,
                                  selectedHistory,
                                ),
                              ),
                            ),
                          ] else if (filteredHistories.isNotEmpty) ...[
                            Dimens.spacing.horizontal(Dimens.size16),
                            const Expanded(
                              flex: 4,
                              child: _SelectHistoryHint(),
                            ),
                          ],
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistoryPlaceholder extends StatelessWidget {
  const _EmptyHistoryPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: Dimens.size64,
            color: context.colorScheme.onSurfaceVariant,
          ),
          Dimens.spacing.vertical(Dimens.size16),
          Text(
            AppLang.messagesNoHistoryFound.tr(),
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectHistoryHint extends StatelessWidget {
  const _SelectHistoryHint();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: Dimens.radii.borderMedium(),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: Dimens.size48,
              color: context.colorScheme.onSurfaceVariant,
            ),
            Dimens.spacing.vertical(Dimens.size12),
            Text(
              AppLang.labelsSelectHistoryHint.tr(),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
