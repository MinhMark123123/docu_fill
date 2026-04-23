import 'package:core/const/const.dart';
import 'package:localization/localization.dart';

enum TemplateMenuItem {
  edit,
  exportSetting,
  delete;

  String label() {
    switch (this) {
      case TemplateMenuItem.edit:
        return AppLang.actionsEdit.tr();
      case TemplateMenuItem.delete:
        return AppLang.actionsDelete.tr();
      case TemplateMenuItem.exportSetting:
        return AppLang.actionsExportData.tr();
    }
  }
}
