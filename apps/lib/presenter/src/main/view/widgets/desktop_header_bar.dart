import 'package:docu_fill/ui/ui.dart';
import 'package:docu_fill/utils/src/context_extension.dart';
import 'package:flutter/material.dart';

class DesktopHeaderBar extends StatelessWidget {
  final String? title;
  final List<Widget>? trailChildren;
  final List<Widget>? leadingChildren;
  final double? spacing;
  final bool hasShadow;

  const DesktopHeaderBar({
    super.key,
    this.title,
    this.trailChildren,
    this.leadingChildren,
    this.spacing,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      spacing: spacing ?? Dimens.size32,
      children: [
        if (title != null) Text(title!, style: context.textTheme.headlineSmall),
        ...?leadingChildren,
        Dimens.spacing.spacer(),
        ...?trailChildren,
      ],
    );
    if (hasShadow) {
      return BottomShadowContainer(
        backgroundColor: context.colorScheme.surface,
        shadowBlurRadius: Dimens.size2,
        shadowOffset: Offset(0, Dimens.size2),
        padding: EdgeInsets.symmetric(
          vertical: Dimens.size12,
          horizontal: Dimens.size20,
        ),
        height: Dimens.size65,
        child: child,
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Dimens.size12,
        horizontal: Dimens.size20,
      ),
      height: Dimens.size65,
      child: child,
    );
  }
}
