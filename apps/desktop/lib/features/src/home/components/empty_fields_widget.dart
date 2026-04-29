import 'package:design/ui.dart';
import 'package:flutter/material.dart';

class EmptyFieldsWidget extends StatelessWidget {
  const EmptyFieldsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(Dimens.size32),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest.withOpacity(
                0.2,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.article_outlined,
              size: Dimens.size64,
              color: context.colorScheme.primary.withOpacity(0.4),
            ),
          ),
          Dimens.spacing.vertical(Dimens.size24),
          Text(
            "No Templates Selected",
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onSurface,
            ),
          ),
          Dimens.spacing.vertical(Dimens.size8),
          Text(
            "Select one or more templates from the left sidebar to start filling data.",
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
