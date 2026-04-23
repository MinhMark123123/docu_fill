import 'package:localization/localization.dart';
import 'package:core/core.dart';
import 'package:design/ui.dart';
import 'package:flutter/material.dart';

class AddOnInputText extends StatefulWidget {
  final Function(List<String>)? onChanged;
  final List<String?>? initValue;

  const AddOnInputText({super.key, this.onChanged, this.initValue});

  @override
  State<AddOnInputText> createState() => _AddOnInputTextState();
}

class _AddOnInputTextState extends State<AddOnInputText> {
  final List<String?> _values = [];

  @override
  void initState() {
    super.initState();
    _initValues();
  }

  void _initValues() {
    _values.clear();
    if (widget.initValue != null && widget.initValue!.isNotEmpty) {
      _values.addAll(widget.initValue!);
    } else {
      _values.add(null);
    }
  }

  @override
  void didUpdateWidget(covariant AddOnInputText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initValue != oldWidget.initValue) {
      setState(() {
        _initValues();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_values.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: Dimens.size12),
            child: _buildInput(
              index: index,
              initValue: _values[index],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () => addItem(),
          icon: const Icon(Icons.add),
          label: Text(AppLang.actionsAdd.tr()),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void addItem() {
    setState(() {
      _values.add(null);
    });
  }

  void removeItem(int index) {
    setState(() {
      if (_values.length > 1) {
        _values.removeAt(index);
        notifyOutText();
      }
    });
  }

  Widget _buildInput({
    required int index,
    String? initValue,
  }) {
    return TextFormField(
      key: ValueKey('input_$index'),
      initialValue: initValue,
      decoration: InputDecoration(
        hintText: AppLang.messagesInputTextHint.tr(),
        border: const OutlineInputBorder(),
        suffixIcon: index == 0
            ? null
            : IconButton(
                onPressed: () => removeItem(index),
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              ),
      ),
      onChanged: (value) {
        _values[index] = value;
        notifyOutText();
      },
    );
  }

  Future<void> notifyOutText() async {
    final nonNullValues = _values.where((e) => e != null).map((e) => e!);
    widget.onChanged?.call(nonNullValues.toList());
  }
}
