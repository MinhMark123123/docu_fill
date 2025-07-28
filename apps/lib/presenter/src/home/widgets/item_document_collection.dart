import 'package:docu_fill/gen/assets.gen.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:docu_fill/utils/src/context_extension.dart';
import 'package:flutter/material.dart';

class ItemDocumentCollection extends StatelessWidget {
  final String id;
  final String title;

  const ItemDocumentCollection({
    super.key,
    required this.id,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Dimens.size16,
      children: [
        AspectRatio(
          aspectRatio: 160 / 213,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: Dimens.radii.medium()),
            child: SmartImage(
              path: Assets.images.png.imageDocument.path,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Text(title, style: context.textTheme.bodySmall),
      ],
    );
  }
}
