import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/presenter/src/main/view/widgets/desktop_header_bar.dart';
import 'package:docu_fill/presenter/src/main/view_model/main_view_model.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class MainLayoutDesktop extends StatelessWidget {
  final Widget child;

  const MainLayoutDesktop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [headerBar(), Expanded(child: child)]),
    );
  }

  Widget headerBar() {
    final items = MainDesktopMenu.values;

    return StreamDataConsumer(
      streamData: getViewModel<MainViewModel>().currentMenu,
      builder: (context, currentMenu) {
        final style = context.textTheme.titleMedium;
        return DesktopHeaderBar(
          title: AppLang.appName.tr(),
          leadingChildren: itemMenuList(context, items, currentMenu, style),
          trailChildren: [AppAvatar(displayName: "")],
        );
      },
    );
  }

  List<Transform> itemMenuList(
    BuildContext context,
    List<MainDesktopMenu> items,
    MainDesktopMenu currentMenu,
    TextStyle? style,
  ) {
    return items.map((e) {
      final textStyle =
          e == currentMenu
              ? style?.copyWith(fontWeight: FontWeight.bold)
              : style;
      return Transform.translate(
        offset: Offset(0, 0),
        child: TextButton(
          onPressed: () {
            getViewModel<MainViewModel>().selectMenu(context, e);
          },
          child: Text(e.label(), style: textStyle),
        ),
      );
    }).toList();
  }

  Widget body() {
    return Placeholder();
  }
}
