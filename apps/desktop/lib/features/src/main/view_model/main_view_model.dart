import 'package:localization/localization.dart';
import 'package:core/core.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/route/routers.dart';
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
    if (menu == _currentMenu.data &&
        GoRouter.of(context).state.fullPath == menu.pathRoute) {
      return;
    }
    _currentMenu.postValue(menu);
    navigatePage(menu.pathRoute);
  }
}

enum MainDesktopMenu {
  template,
  upload,
  setting;

  String label() {
    switch (this) {
      case MainDesktopMenu.template:
        return AppLang.labelsTemplates.tr();
      case MainDesktopMenu.upload:
        return AppLang.actionsUpload.tr();
      case MainDesktopMenu.setting:
        return AppLang.labelsSettings.tr();
    }
  }

  IconData icon() {
    switch (this) {
      case MainDesktopMenu.template:
        return Icons.description_outlined;
      case MainDesktopMenu.upload:
        return Icons.upload_file_outlined;
      case MainDesktopMenu.setting:
        return Icons.settings_outlined;
    }
  }

  IconData selectedIcon() {
    switch (this) {
      case MainDesktopMenu.template:
        return Icons.description;
      case MainDesktopMenu.upload:
        return Icons.upload_file;
      case MainDesktopMenu.setting:
        return Icons.settings;
    }
  }

  String get pathRoute {
    switch (this) {
      case MainDesktopMenu.template:
        return RoutesPath.home;
      case MainDesktopMenu.upload:
        return RoutesPath.homeUpload;
      case MainDesktopMenu.setting:
        return RoutesPath.setting;
    }
  }
}
