import 'package:docu_fill/ui/ui.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';

class DesktopTopTitle extends StatelessWidget {
  final double aspectRatio;
  final String title;
  final String subtitle;

  const DesktopTopTitle({
    super.key,
    required this.aspectRatio,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.size16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: context.textTheme.displayLarge),
            Dimens.spacing.vertical(Dimens.size12),
            Text(
              subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.appColors?.bodyTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
