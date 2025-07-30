import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/route/routers.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

part 'main_view_model.g.dart';

@BindableViewModel()
class MainViewModel extends BaseViewModel {
  @Bind()
  late final _currentMenu = MainDesktopMenu.template.mtd(this);

  void selectMenu(BuildContext context, MainDesktopMenu menu) {
    if (menu == _currentMenu.data) return;

    _currentMenu.postValue(menu);
    if (GoRouter.of(context).state.path != menu.pathRoute) {
      navigatePage(menu.pathRoute);
    }
  }
}

enum MainDesktopMenu {
  template,
  setting;

  String label() {
    switch (this) {
      case MainDesktopMenu.template:
        return AppLang.labelsTemplates.tr();
      case MainDesktopMenu.setting:
        return AppLang.labelsSettings.tr();
    }
  }

  String get pathRoute {
    switch (this) {
      case MainDesktopMenu.template:
        return RoutesPath.home;
      case MainDesktopMenu.setting:
        return RoutesPath.setting;
    }
  }
}
