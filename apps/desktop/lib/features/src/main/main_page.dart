import 'package:design/ui.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/features/page.dart';
import 'package:docu_fill/features/src/main/view_model/main_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:go_router/go_router.dart';

class MainPage extends BaseView<MainViewModel> {
  final Widget child;
  final GoRouterState state;

  const MainPage({super.key, required this.child, required this.state});

  @override
  Widget build(BuildContext context, MainViewModel viewModel) {
    viewModel.syncMenu(state.uri);
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
                    viewModel.railMenus.map((e) {
                      return NavigationRailDestination(
                        icon: Icon(e.icon()),
                        selectedIcon: Icon(e.selectedIcon()),
                        label: Text(e.label()),
                      );
                    }).toList(),
                selectedIndex: viewModel.railMenus.contains(currentMenu)
                    ? viewModel.railMenus.indexOf(currentMenu)
                    : null,
                onDestinationSelected: (index) {
                  viewModel.selectMenu(context, viewModel.railMenus[index]);
                },
                leading: Padding(
                  padding: EdgeInsets.symmetric(vertical: Dimens.size24),
                  child: Tooltip(
                    message: AppLang.labelsDashboard.tr(),
                    child: InkWell(
                      onTap: () {
                        viewModel.selectMenu(context, MainDesktopMenu.dashboard);
                      },
                      customBorder: const CircleBorder(),
                      child: AppAvatar(displayName: ""),
                    ),
                  ),
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
}
