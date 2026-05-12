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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit, color: context.colorScheme.primary),
          Dimens.spacing.horizontal(Dimens.size12),
          Expanded(
            child: Text(
              AppLang.labelsConfigureTemplateFields.tr(),
              style: context.textTheme.titleLarge,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildSection(
                      context,
                      AppLang.labelsFieldKey.tr(),
                      CellFieldKey(data: _tempData),
                    ),
                  ),
                  Dimens.spacing.horizontal(Dimens.size16),
                  Expanded(
                    child: _buildSection(
                      context,
                      AppLang.labelsRequired.tr(),
                      CellFieldRequired(
                        data: _tempData,
                        onChanged: (value) {
                          setState(() {
                            _tempData = _tempData.copyWith(
                              isRequired: value ?? false,
                            );
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              _buildSection(
                context,
                AppLang.labelsFieldName.tr(),
                CellFieldName(
                  data: _tempData,
                onChanged: (value) {
                  setState(() {
                    _tempData.fieldName = value.trim().isEmpty ? null : value;
                  });
                },
                ),
              ),
              _buildSection(
                context,
                AppLang.labelsSection.tr(),
                CellFieldSection(
                  data: _tempData,
                onChanged: (value) {
                  setState(() {
                    _tempData.section = value.trim().isEmpty ? null : value;
                  });
                },
                ),
              ),
              _buildSection(
                context,
                AppLang.labelsInputType.tr(),
                CellFieldInput(
                  data: _tempData,
                  onChanged: (value) {
                    setState(() {
                      _tempData = _tempData.copyWith(inputType: value);
                    });
                  },
                ),
              ),
              _buildSection(
                context,
                AppLang.labelsOptions.tr(),
                CellFieldOptions(
                  data: _tempData,
                  onChanged: (updated) {
                    setState(() {
                      _tempData = updated;
                    });
                  },
                ),
              ),
              _buildSection(
                context,
                AppLang.labelsDefaultValue.tr(),
                CellDefaultValue(
                  data: _tempData,
                onChanged: (value) {
                  setState(() {
                    _tempData.defaultValue = value.trim().isEmpty ? null : value;
                  });
                },
                ),
              ),
              _buildSection(
                context,
                AppLang.labelsPrompt.tr(),
                CellFieldDescription(
                  data: _tempData,
                onChanged: (value) {
                  setState(() {
                    _tempData.description = value.trim().isEmpty ? null : value;
                  });
                },
                ),
              ),
              _buildSection(
                context,
                AppLang.labelsGeneralInfo.tr(),
                CellAdditionalInfo(
                  data: _tempData,
                onChanged: (value) {
                  setState(() {
                    _tempData.additionalInfo = value.trim().isEmpty ? null : value;
                  });
                },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            getViewModel<ConfigureViewModel>().updateField(
              widget.data.fieldKey,
              (d) => _tempData,
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.primary,
            foregroundColor: context.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: Dimens.radii.borderMedium(),
            ),
          ),
          child: Text(AppLang.actionsConfirm.tr()),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String label, Widget child) {
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
