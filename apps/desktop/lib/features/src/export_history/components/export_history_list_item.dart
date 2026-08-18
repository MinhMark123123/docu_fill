import 'package:data/data.dart';
import 'package:design/ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class ExportHistoryListItem extends StatelessWidget {
  final ExportHistory history;
  final bool isSelected;
  final VoidCallback onTap;

  const ExportHistoryListItem({
    super.key,
    required this.history,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(context, history.status);
    final statusText = _getStatusText(history.status);

    return Card(
      elevation: isSelected ? 4 : 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: Dimens.radii.borderMedium(),
        side: BorderSide(
          color: isSelected
              ? context.colorScheme.primary
              : context.colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      margin: EdgeInsets.only(bottom: Dimens.size12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(Dimens.size16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      history.baseFileName,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimens.size8,
                      vertical: Dimens.size4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: Dimens.radii.borderSmall(),
                    ),
                    child: Text(
                      statusText,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Dimens.spacing.vertical(Dimens.size8),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(history.createdAt),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              Dimens.spacing.vertical(Dimens.size12),
              Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: Dimens.size16,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  Dimens.spacing.horizontal(Dimens.size4),
                  Expanded(
                    child: Text(
                      history.templateSnapshots.map((e) => e.templateName).join(', '),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context, ExportHistoryStatus status) {
    switch (status) {
      case ExportHistoryStatus.success:
        return Colors.green;
      case ExportHistoryStatus.partialSuccess:
        return Colors.orange;
      case ExportHistoryStatus.failed:
        return Colors.red;
    }
  }

  String _getStatusText(ExportHistoryStatus status) {
    switch (status) {
      case ExportHistoryStatus.success:
        return AppLang.labelsSuccess.tr();
      case ExportHistoryStatus.partialSuccess:
        return AppLang.labelsPartialSuccess.tr();
      case ExportHistoryStatus.failed:
        return AppLang.labelsFailed.tr();
    }
  }
}
