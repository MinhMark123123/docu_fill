import 'package:data/data.dart';
import 'package:design/ui.dart';
import 'package:docu_fill/features/src/configure/components/cell_additional_info.dart';
import 'package:docu_fill/features/src/configure/components/cell_default_value.dart';
import 'package:docu_fill/features/src/configure/components/cell_field_description.dart';
import 'package:docu_fill/features/src/configure/components/cell_field_name.dart';
import 'package:docu_fill/features/src/configure/components/cell_field_options.dart';
import 'package:docu_fill/features/src/configure/components/cell_field_required.dart';
import 'package:docu_fill/features/src/configure/components/cell_field_section.dart';
import 'package:docu_fill/features/src/configure/model/table_row_data.dart';
import 'package:docu_fill/features/src/configure/view_model/configure_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

import 'cell_field_input.dart';
import 'cell_field_key.dart';

class ConfigureEditDialog extends StatefulWidget {
  final TableRowData data;

  const ConfigureEditDialog({super.key, required this.data});

  @override
  State<ConfigureEditDialog> createState() => _ConfigureEditDialogState();
}

class _ConfigureEditDialogState extends State<ConfigureEditDialog> {
  late TableRowData _tempData;

  @override
  void initState() {
    super.initState();
    _tempData = widget.data.copyWith();
  }

  void _onConfirm() {
    getViewModel<ConfigureViewModel>().updateField(
      widget.data.fieldKey,
      (d) => _tempData,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _DialogHeader(onClose: () => Navigator.pop(context)),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KeyAndRequiredRow(
                data: _tempData,
                onRequiredChanged:
                    (value) => setState(() {
                      _tempData = _tempData.copyWith(
                        isRequired: value ?? false,
                      );
                    }),
              ),
              _DialogSection(
                label: AppLang.labelsFieldName.tr(),
                child: CellFieldName(
                  data: _tempData,
                  onChanged:
                      (value) => setState(() {
                        _tempData.fieldName =
                            value.trim().isEmpty ? null : value;
                      }),
                ),
              ),
              _DialogSection(
                label: AppLang.labelsSection.tr(),
                child: CellFieldSection(
                  data: _tempData,
                  onChanged:
                      (value) => setState(() {
                        _tempData.section = value.trim().isEmpty ? null : value;
                      }),
                ),
              ),
              _DialogSection(
                label: AppLang.labelsInputType.tr(),
                child: CellFieldInput(
                  data: _tempData,
                  onChanged:
                      (value) => setState(() {
                        _tempData = _tempData.copyWith(inputType: value);
                      }),
                ),
              ),
              if (_tempData.inputType == FieldType.selection)
                _DialogSection(
                  label: AppLang.labelsOptions.tr(),
                  child: CellFieldOptions(
                    data: _tempData,
                    onChanged: (updated) => setState(() => _tempData = updated),
                  ),
                ),
              _DialogSection(
                label: AppLang.labelsDefaultValue.tr(),
                child: CellDefaultValue(
                  data: _tempData,
                  onChanged:
                      (value) => setState(() {
                        _tempData.defaultValue =
                            value.trim().isEmpty ? null : value;
                      }),
                ),
              ),
              _DialogSection(
                label: AppLang.labelsPrompt.tr(),
                child: CellFieldDescription(
                  data: _tempData,
                  onChanged:
                      (value) => setState(() {
                        _tempData.description =
                            value.trim().isEmpty ? null : value;
                      }),
                ),
              ),
              _DialogSection(
                label: AppLang.labelsGeneralInfo.tr(),
                child: CellAdditionalInfo(
                  data: _tempData,
                  onChanged:
                      (value) => setState(() {
                        _tempData.additionalInfo =
                            value.trim().isEmpty ? null : value;
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [_ConfirmButton(onPressed: _onConfirm)],
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _DialogHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.edit, color: context.colorScheme.primary),
        Dimens.spacing.horizontal(Dimens.size12),
        Expanded(
          child: Text(
            AppLang.labelsConfigureTemplateFields.tr(),
            style: context.textTheme.titleLarge,
          ),
        ),
        IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
      ],
    );
  }
}

class _DialogSection extends StatelessWidget {
  final String label;
  final Widget child;

  const _DialogSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimens.size20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          Dimens.spacing.vertical(Dimens.size8),
          child,
        ],
      ),
    );
  }
}

class _KeyAndRequiredRow extends StatelessWidget {
  final TableRowData data;
  final ValueChanged<bool?> onRequiredChanged;

  const _KeyAndRequiredRow({
    required this.data,
    required this.onRequiredChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _DialogSection(
            label: AppLang.labelsFieldKey.tr(),
            child: CellFieldKey(data: data),
          ),
        ),
        Dimens.spacing.horizontal(Dimens.size16),
        Expanded(
          child: _DialogSection(
            label: AppLang.labelsRequired.tr(),
            child: CellFieldRequired(data: data, onChanged: onRequiredChanged),
          ),
        ),
      ],
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ConfirmButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.colorScheme.primary,
        foregroundColor: context.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: Dimens.radii.borderMedium(),
        ),
      ),
      child: Text(AppLang.actionsConfirm.tr()),
    );
  }
}
