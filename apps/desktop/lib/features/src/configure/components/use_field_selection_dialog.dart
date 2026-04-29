import 'package:data/data.dart';
import 'package:design/ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class UseFieldSelectionDialog extends StatefulWidget {
  final List<TemplateField> currentFields;
  final TemplateConfig selectedOldTemplate;
  final Function(List<TemplateField> selectedFields) onApply;

  const UseFieldSelectionDialog({
    super.key,
    required this.currentFields,
    required this.selectedOldTemplate,
    required this.onApply,
  });

  @override
  State<UseFieldSelectionDialog> createState() =>
      _UseFieldSelectionDialogState();
}

class _UseFieldSelectionDialogState extends State<UseFieldSelectionDialog> {
  final Map<String, bool> _selectionMap = {};
  late List<TemplateField> _matchingFields;

  @override
  void initState() {
    super.initState();
    final currentKeys = widget.currentFields.map((e) => e.key).toSet();

    // Find fields in the old template that have the same key as current fields
    _matchingFields =
        widget.selectedOldTemplate.fields
            .where((f) => currentKeys.contains(f.key))
            .toList();

    for (var field in _matchingFields) {
      _selectionMap[field.key] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLang.labelsImportConfiguration.tr()),
          Text(
            "${AppLang.labelsTemplateName.tr()}: ${widget.selectedOldTemplate.templateName}",
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.primary,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            if (_matchingFields.isEmpty)
              Expanded(
                child: Center(
                  child: Text(AppLang.messagesNoMatchingFields.tr()),
                ),
              )
            else ...[
              CheckboxListTile(
                value: _selectionMap.values.every((v) => v),
                onChanged: (val) {
                  setState(() {
                    _selectionMap.updateAll((k, v) => val ?? false);
                  });
                },
                title: Text(
                  AppLang.labelsSelectAll.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _matchingFields.length,
                  itemBuilder: (context, index) {
                    final field = _matchingFields[index];
                    return CheckboxListTile(
                      value: _selectionMap[field.key],
                      onChanged: (val) {
                        setState(() {
                          _selectionMap[field.key] = val ?? false;
                        });
                      },
                      title: Text(
                        field.label.isNotEmpty ? field.label : field.key,
                      ),
                      subtitle: Text(
                        "${AppLang.labelsKey.tr()}: ${field.key} | ${AppLang.labelsInputType.tr()}: ${field.type.label()}",
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLang.actionsCancel.tr()),
        ),
        ElevatedButton(
          onPressed:
              _matchingFields.isEmpty
                  ? null
                  : () {
                    final selected =
                        _matchingFields
                            .where((f) => _selectionMap[f.key] == true)
                            .toList();
                    widget.onApply(selected);
                    Navigator.pop(context);
                  },
          child: Text(AppLang.actionsApply.tr()),
        ),
      ],
    );
  }
}
