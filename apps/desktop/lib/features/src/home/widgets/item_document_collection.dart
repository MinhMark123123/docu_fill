import 'package:core/core.dart';
import 'package:design/ui.dart';
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
    final bgColor =
        isSelected
            ? context.colorScheme.primary.withOpacity(0.08)
            : Colors.transparent;
    final borderColor =
        isSelected
            ? context.colorScheme.primary.withOpacity(0.5)
            : context.colorScheme.outlineVariant.withOpacity(0.5);
    final textColor =
        isSelected
            ? context.colorScheme.primary
            : context.colorScheme.onSurface;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Dimens.size12,
        vertical: Dimens.size4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: Dimens.radii.borderMedium(),
        border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: Dimens.radii.borderMedium(),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Dimens.size12,
          vertical: Dimens.size4,
        ),
        leading: Icon(
          Icons.insert_drive_file_outlined,
          color:
              isSelected
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
        subtitle:
            subtitle == null
                ? null
                : Text(
                  subtitle!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
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
