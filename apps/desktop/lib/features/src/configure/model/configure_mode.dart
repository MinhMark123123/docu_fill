import 'package:data/data.dart';
import 'package:docu_fill/core/src/events.dart';

enum ConfigureMode {
  addNew,
  edit,
  importSetting;

  String get valueString => toString().split('.').last;

  static ConfigureMode? fromString(String? value) {
    if (value == null) return null;
    return ConfigureMode.values.firstWhere(
      (e) => e.valueString == value,
      orElse: () => ConfigureMode.addNew,
    );
  }

  bool get isImportMode => this == ConfigureMode.importSetting;

  bool get isEdit => this == ConfigureMode.edit;

  bool get isAddNew => this == ConfigureMode.addNew;
}

class ShowUseSettingDialogEvent extends ShowDialogEvent<void> {
  final List<TemplateConfig> listTemplate;

  ShowUseSettingDialogEvent({
    super.actions,
    required this.listTemplate,
    super.content,
    super.onCompleted,
    super.title,
  });

  @override
  ShowUseSettingDialogEvent copyWith({
    String? title,
    String? content,
    List<DialogAction>? actions,
    List<TemplateConfig>? listTemplate,
    List<String>? options,
    Function(void)? onCompleted,
  }) {
    return ShowUseSettingDialogEvent(
      listTemplate: listTemplate ?? this.listTemplate,
      title: title ?? this.title,
      content: content ?? this.content,
      actions: actions ?? this.actions,
      onCompleted: onCompleted ?? this.onCompleted,
    );
  }
}
