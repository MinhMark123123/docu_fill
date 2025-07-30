import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/gen/assets.gen.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:docu_fill/utils/src/context_extension.dart';
import 'package:flutter/material.dart';

class ItemDocumentCollection extends StatelessWidget {
  final String id;
  final String title;
  final Function() onItemPressed;
  final bool isSelected;

  const ItemDocumentCollection({
    super.key,
    this.isSelected = false,
    required this.id,
    required this.title,
    required this.onItemPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: Dimens.radii.borderLarge(),
        color: AppConst.documentColor,
        border:
            isSelected ? Border.all(color: context.colorScheme.primary) : null,
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 160 / 213,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: Dimens.radii.borderMedium(),
                  ),
                  child: SmartImage(
                    path: Assets.images.png.imageDocument.path,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: Dimens.size6,
            child: Text(
              title,
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: Dimens.radii.borderLarge(),
                onTap: () => onItemPressed.call(),
                //child: SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
