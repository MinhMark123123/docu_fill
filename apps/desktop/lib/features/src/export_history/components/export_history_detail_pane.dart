import 'dart:io';

import 'package:data/data.dart';
import 'package:design/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';
import 'package:path/path.dart' as p;

class ExportHistoryDetailPane extends StatelessWidget {
  final ExportHistory history;
  final VoidCallback onReExport;
  final VoidCallback onRestore;

  const ExportHistoryDetailPane({
    super.key,
    required this.history,
    required this.onReExport,
    required this.onRestore,
  });

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
        padding: EdgeInsets.all(Dimens.size24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  _buildMetadata(context),
                  Dimens.spacing.vertical(Dimens.size16),
                  _buildOutputFiles(context),
                  Dimens.spacing.vertical(Dimens.size16),
                  _buildFieldValues(context),
                ],
              ),
            ),
            const Divider(),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.assignment_outlined,
          color: context.colorScheme.primary,
          size: Dimens.size28,
        ),
        Dimens.spacing.horizontal(Dimens.size12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLang.labelsExportHistoryDetail.tr(),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(history.createdAt),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context,
          AppLang.labelsBaseFileName.tr(),
          history.baseFileName,
        ),
        Dimens.spacing.vertical(Dimens.size8),
        _buildInfoRow(
          context,
          AppLang.labelsExportDirectory.tr(),
          history.exportDirectory,
          trailing: IconButton(
            icon: const Icon(Icons.folder_open_outlined),
            onPressed: () => _openDirectory(history.exportDirectory),
            tooltip: AppLang.actionsOpenFolder.tr(),
          ),
        ),
        Dimens.spacing.vertical(Dimens.size8),
        _buildInfoRow(
          context,
          AppLang.labelsDocumentCount.tr(),
          "${history.documentCount}",
        ),
      ],
    );
  }

  Widget _buildOutputFiles(BuildContext context) {
    if (history.outputFiles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLang.labelsOutputFiles.tr(),
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Dimens.spacing.vertical(Dimens.size8),
        ...history.outputFiles.map((path) {
          final filename = p.basename(path);
          return Card(
            elevation: 0,
            color: context.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: Dimens.radii.borderSmall(),
              side: BorderSide(color: context.colorScheme.outlineVariant),
            ),
            margin: EdgeInsets.only(bottom: Dimens.size4),
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: Text(filename),
              subtitle: Text(
                path,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy_outlined),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: path));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLang.messagesPathCopied.tr()),
                        ),
                      );
                    },
                    tooltip: AppLang.actionsCopyPath.tr(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new_outlined),
                    onPressed: () => _openFile(path),
                    tooltip: AppLang.actionsOpen.tr(),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFieldValues(BuildContext context) {
    if (history.fieldValues.isEmpty && history.singleLineValues.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLang.labelsInputValues.tr(),
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Dimens.spacing.vertical(Dimens.size8),
        Table(
          columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2)},
          border: TableBorder.all(
            color: context.colorScheme.outlineVariant,
            width: 0.5,
          ),
          children: [
            ...history.singleLineValues.entries.map((e) {
              return TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(Dimens.size8),
                    child: Text(
                      e.value.label,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(Dimens.size8),
                    child: Text(e.value.value ?? "-"),
                  ),
                ],
              );
            }),
            ...history.fieldValues.entries.map((e) {
              return TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(Dimens.size8),
                    child: Text(
                      e.value.label,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(Dimens.size8),
                    child: Text(e.value.value ?? "-"),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: Dimens.size16),
              shape: RoundedRectangleBorder(
                borderRadius: Dimens.radii.borderSmall(),
              ),
            ),
            onPressed:
                () => _confirmAction(
                  context,
                  title: AppLang.actionsRestoreToForm.tr(),
                  message: AppLang.messagesRestoreConfirm.tr(),
                  onConfirm: onRestore,
                ),
            icon: const Icon(Icons.settings_backup_restore),
            label: Text(AppLang.actionsRestoreToForm.tr()),
          ),
        ),
        Dimens.spacing.horizontal(Dimens.size12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colorScheme.primary,
              foregroundColor: context.colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(vertical: Dimens.size16),
              shape: RoundedRectangleBorder(
                borderRadius: Dimens.radii.borderSmall(),
              ),
            ),
            onPressed:
                () => _confirmAction(
                  context,
                  title: AppLang.actionsReExport.tr(),
                  message: AppLang.messagesReExportConfirm.tr(),
                  onConfirm: onReExport,
                ),
            icon: const Icon(Icons.sync_outlined),
            label: Text(AppLang.actionsReExport.tr()),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(value, style: context.textTheme.bodyMedium),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  void _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppLang.actionsCancel.tr()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onConfirm();
                },
                child: Text(AppLang.actionsConfirm.tr()),
              ),
            ],
          ),
    );
  }

  void _openDirectory(String path) {
    if (Platform.isMacOS) {
      Process.run('open', [path]);
    } else if (Platform.isWindows) {
      Process.run('explorer.exe', [path]);
    }
  }

  void _openFile(String path) {
    if (Platform.isMacOS) {
      Process.run('open', [path]);
    } else if (Platform.isWindows) {
      Process.run('explorer.exe', [path]);
    }
  }
}
