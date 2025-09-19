import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/utils/utils.dart';

enum TemplateMenuItem {
  edit,
  delete;

  String label() {
    switch (this) {
      case TemplateMenuItem.edit:
        return AppLang.actionsEdit.tr();
      case TemplateMenuItem.delete:
        return AppLang.actionsDelete.tr();
    }
  }
}
