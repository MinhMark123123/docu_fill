import 'package:design/ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class TopTemplatesPanel extends StatelessWidget {
  final List<MapEntry<String, int>> topTemplates;

  const TopTemplatesPanel({
    super.key,
    required this.topTemplates,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: Dimens.radii.borderMedium(),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(Dimens.size24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLang.labelsTopTemplates.tr(),
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Dimens.spacing.vertical(Dimens.size16),
            Expanded(
              child: topTemplates.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      itemCount: topTemplates.length,
                      itemBuilder: (context, index) {
                        final entry = topTemplates[index];
                        return _buildTemplateItem(context, index, entry.key, entry.value);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateItem(BuildContext context, int index, String name, int count) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimens.size8),
      child: Row(
        children: [
          Container(
            width: Dimens.size24,
            height: Dimens.size24,
            decoration: BoxDecoration(
              color: index == 0
                  ? context.colorScheme.primary
                  : context.colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              "${index + 1}",
              style: context.textTheme.labelSmall?.copyWith(
                color: index == 0
                    ? context.colorScheme.onPrimary
                    : context.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Dimens.spacing.horizontal(Dimens.size16),
          Expanded(
            child: Text(
              name,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "$count ${AppLang.labelsFiles.tr()}",
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'No usage statistics available.',
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
