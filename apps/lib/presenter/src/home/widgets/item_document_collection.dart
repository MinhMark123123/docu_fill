import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/gen/assets.gen.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';

class ItemDocumentCollection extends StatelessWidget {
  final String id;
  final String title;
  final String? subtitle;
  final Function() onItemPressed;
  final Function(TemplateMenuItem itemMenu) onOptionsMenuPress;
  final bool isSelected;

  const ItemDocumentCollection({
    super.key,
    this.isSelected = false,
    required this.id,
    required this.title,
    this.subtitle,
    required this.onItemPressed,
    required this.onOptionsMenuPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: Dimens.radii.borderSmall(),
        side:
            isSelected
                ? BorderSide(color: context.colorScheme.primary)
                : BorderSide.none,
      ),
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        contentPadding: EdgeInsets.only(
          left: Dimens.size12,
          top: Dimens.size12,
          bottom: Dimens.size12,
        ),
        leading: Assets.images.png.imageDocument.image(),
        title: Text(title, style: context.textTheme.bodyMedium),
        subtitle:
            subtitle == null
                ? null
                : Text(subtitle!, style: context.textTheme.bodySmall),
        onTap: () => onItemPressed.call(),
        trailing: trailingMenu(),
      ),
    );
  }

  Widget trailingMenu() {
    return MenuAnchor(
      builder: (
        BuildContext context,
        MenuController controller,
        Widget? child,
      ) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.more_horiz),
          tooltip: AppLang.actionsShowMenu.tr(),
        );
      },
      menuChildren: List<MenuItemButton>.generate(
        TemplateMenuItem.values.length,
        (int index) => MenuItemButton(
          onPressed: () {
            onOptionsMenuPress.call(TemplateMenuItem.values[index]);
          },
          child: Text(TemplateMenuItem.values[index].label()),
        ),
      ),
    );
  }
}
