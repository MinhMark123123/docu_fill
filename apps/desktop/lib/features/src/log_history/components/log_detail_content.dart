import 'package:design/ui.dart';
import 'package:flutter/material.dart';

class LogDetailContent extends StatelessWidget {
  final String fileName;
  final String content;

  const LogDetailContent({
    super.key,
    required this.fileName,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimens.size24),
      child: SelectionArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LogDetailHeader(fileName: fileName),
            Dimens.spacing.vertical(Dimens.size16),
            _LogContentCard(content: content),
          ],
        ),
      ),
    );
  }
}

class _LogDetailHeader extends StatelessWidget {
  final String fileName;
  const _LogDetailHeader({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.file_present, size: 20, color: context.colorScheme.primary),
        Dimens.spacing.horizontal(Dimens.size12),
        Text(
          fileName,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _LogContentCard extends StatelessWidget {
  final String content;
  const _LogContentCard({required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Padding(
        padding: EdgeInsets.all(Dimens.size16),
        child: Text(
          content,
          style: const TextStyle(
            fontFamily: 'monospace',
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
