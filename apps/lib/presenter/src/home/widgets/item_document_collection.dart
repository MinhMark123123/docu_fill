import 'package:docu_fill/const/const.dart';
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
      elevation: Dimens.size2,
      color:
          isSelected
              ? context.colorScheme.primaryFixedDim
              : context.colorScheme.surface,
      surfaceTintColor:
          isSelected
              ? context.colorScheme.primaryFixedDim
              : context.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: Dimens.radii.borderSmall()),
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        contentPadding: EdgeInsets.only(
          left: Dimens.size12,
          top: Dimens.size8,
          bottom: Dimens.size8,
        ),
        leading: Icon(
          Icons.file_copy_outlined,
          color: isSelected ? context.colorScheme.surface : null,
        ),
        title: Text(
          title,
          style: context.textTheme.bodyMedium?.copyWith(
            color: isSelected ? context.colorScheme.surface : null,
          ),
        ),
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
    final childFocusNode = FocusNode();
    return MenuAnchor(
      onClose: () => FocusManager.instance.rootScope.unfocus(),
      childFocusNode: childFocusNode,
      builder: (
        BuildContext context,
        MenuController controller,
        Widget? child,
      ) {
        return IconButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
            childFocusNode.unfocus();
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
            childFocusNode.unfocus();
          },
          child: Text(TemplateMenuItem.values[index].label()),
        ),
      ),
    );
  }
}
