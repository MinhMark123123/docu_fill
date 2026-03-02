import 'package:docu_fill/presenter/page.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:docu_fill/presenter/src/main/view_model/main_view_model.dart';

class MainLayoutDesktop extends StatelessWidget {
  final Widget child;

  const MainLayoutDesktop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<MainViewModel>();
    return Scaffold(
      body: Row(
        children: [
          StreamDataConsumer(
            streamData: viewModel.currentMenu,
            builder: (context, currentMenu) {
              return NavigationRail(
                extended: false,
                labelType: NavigationRailLabelType.all,
                backgroundColor: context.colorScheme.surface,
                indicatorColor: context.colorScheme.primaryContainer,
                selectedIconTheme: IconThemeData(
                  color: context.colorScheme.primary,
                ),
                unselectedIconTheme: IconThemeData(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                selectedLabelTextStyle: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelTextStyle: context.textTheme.labelSmall
                    ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                destinations:
                    MainDesktopMenu.values.map((e) {
                      return NavigationRailDestination(
                        icon: Icon(e.icon()),
                        selectedIcon: Icon(e.selectedIcon()),
                        label: Text(e.label()),
                      );
                    }).toList(),
                selectedIndex: MainDesktopMenu.values.indexOf(currentMenu),
                onDestinationSelected: (index) {
                  viewModel.selectMenu(context, MainDesktopMenu.values[index]);
                },
                leading: Padding(
                  padding: EdgeInsets.symmetric(vertical: Dimens.size24),
                  child: AppAvatar(displayName: ""),
                ),
              );
            },
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: context.colorScheme.outlineVariant,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget body() {
    return const Placeholder();
  }
}
