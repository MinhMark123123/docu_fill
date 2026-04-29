import 'package:data/data.dart';
import 'package:design/ui.dart';
import 'package:docu_fill/features/src/home/view_model/fields_input_view_model.dart';
import 'package:docu_fill/features/src/home/widgets/image_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class FieldItemBuilder extends StatelessWidget {
  final TemplateField field;

  const FieldItemBuilder({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case FieldType.text:
      case FieldType.singleLine:
        return TextInputFieldItem(field: field);
      case FieldType.datetime:
        return DateTimePickerFieldItem(field: field);
      case FieldType.selection:
        return SelectionFieldItem(field: field);
      case FieldType.image:
        return ImagePickerFieldItem(field: field);
    }
  }
}

class FieldItemContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isRequired;
  final bool isRow;

  const FieldItemContainer({
    super.key,
    required this.title,
    required this.child,
    this.isRequired = false,
    this.isRow = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleWidget = _FieldTitle(title: title, isRequired: isRequired);

    if (isRow) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: Dimens.size4),
        child: Row(
          children: [
            Expanded(flex: 1, child: titleWidget),
            Dimens.spacing.horizontal(Dimens.size16),
            Expanded(flex: 2, child: child),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimens.size4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [titleWidget, Dimens.spacing.vertical(Dimens.size8), child],
      ),
    );
  }
}

class _FieldTitle extends StatelessWidget {
  final String title;
  final bool isRequired;

  const _FieldTitle({required this.title, required this.isRequired});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: context.colorScheme.onSurface,
        ),
        children: <TextSpan>[
          TextSpan(text: title),
          if (isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(color: context.colorScheme.error),
            ),
        ],
      ),
    );
  }
}

class TextInputFieldItem extends StatelessWidget {
  final TemplateField field;

  const TextInputFieldItem({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return FieldItemContainer(
      title: field.label,
      isRequired: field.required,
      child: ReactiveTextFormField(
        key: Key(field.key),
        initialValue: viewModel.getInitValue(e: field),
        maxLines: 8,
        minLines: 1,
        decoration: InputDecoration(
          hintText:
              field.type == FieldType.text
                  ? AppLang.messagesInputTextHint.tr()
                  : AppLang.messagesSingleLineTextHint.tr(),
        ),
        onChanged: (value) => viewModel.setValue(field: field, value: value),
      ),
    );
  }
}

class DateTimePickerFieldItem extends StatelessWidget {
  final TemplateField field;

  const DateTimePickerFieldItem({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return FieldItemContainer(
      title: field.label,
      isRequired: field.required,
      isRow: true,
      child: DateTimePickerButton(
        initialDateTime: DateTime.tryParse(
          viewModel.getInitValue(e: field) ?? "",
        ),
        onDateTimeChanged:
            (time) => viewModel.setValue(field: field, value: time?.toString()),
      ),
    );
  }
}

class SelectionFieldItem extends StatelessWidget {
  final TemplateField field;

  const SelectionFieldItem({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return FieldItemContainer(
      title: field.label,
      isRequired: field.required,
      child: OutlineDropdownButton(
        initialValue: viewModel.getInitValue(e: field),
        items: field.options ?? [],
        onSelected: (value) => viewModel.setValue(field: field, value: value),
      ),
    );
  }
}

class ImagePickerFieldItem extends StatelessWidget {
  final TemplateField field;

  const ImagePickerFieldItem({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return FieldItemContainer(
      title: field.label,
      isRequired: field.required,
      child: ImagePickerWidget(
        imageFiled: field,
        onImageChanged:
            (image) => viewModel.setValue(field: field, value: image?.path),
      ),
    );
  }
}
