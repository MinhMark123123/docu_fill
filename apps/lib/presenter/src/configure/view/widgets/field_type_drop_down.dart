import 'package:docu_fill/data/data.dart';
import 'package:docu_fill/ui/src/methodology/tokens/dimens.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';

class EnumDropdownButton extends StatefulWidget {
  final FieldType initialValue;
  final ValueChanged<FieldType?> onChanged;
  final String buttonText; // Text for the button itself
  final IconData? buttonIcon; // Optional icon for the button

  const EnumDropdownButton({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.buttonText = "Select Type",
    this.buttonIcon,
  });

  @override
  State<EnumDropdownButton> createState() => _EnumDropdownButtonState();
}

class _EnumDropdownButtonState extends State<EnumDropdownButton> {
  FieldType? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant EnumDropdownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _selectedValue = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraint) {
          return DropdownButton<FieldType>(
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            value: _selectedValue,
            // Hint to display when no value is selected (optional, if you want the button text to change)
            // hint: _selectedValue == null ? Text(widget.buttonText) : null,
            isExpanded: false,
            // Don't expand to fill width like a form field
            // To make it look like a button, we customize the 'underline' and 'selectedItemBuilder' or 'child'
            underline: Container(),
            // Removes the default underline of DropdownButton
            // This is the widget that is displayed when the dropdown is closed (acting as the button)
            // We'll use an ElevatedButton or OutlinedButton style here.
            // For simplicity, using a Container styled to look like a button.
            selectedItemBuilder: (BuildContext context) {
              // This builder is for the item displayed when the dropdown is *closed*
              // It's often the same as the menu items, but can be customized.
              // For a button look, we want a static appearance.
              return FieldType.values.map<Widget>((FieldType item) {
                // This mapping is a bit of a quirk for selectedItemBuilder.
                // We essentially need to provide a list of widgets that *could* be the selected one.
                // The DropdownButton will pick the one corresponding to the current `value`.
                // For a static button look, all these will be the same button appearance.
                return _buildButtonChild(context, constraint.maxWidth);
              }).toList();
            },
            // If selectedItemBuilder is not enough, or you always want a fixed button appearance
            // you can also wrap the DropdownButton in a custom button and use `Opacity` to hide the default arrow,
            // then use `onTap` of your custom button to trigger the dropdown.
            // However, selectedItemBuilder is usually sufficient for this.

            // If you don't use selectedItemBuilder, the child of DropdownMenuItem
            // matching `_selectedValue` will be shown, or the `hint`.
            // To get a button appearance, you'd need `_selectedValue` to be null initially
            // and provide a `hint` that is your button.
            hint: _buildButtonChild(context, constraint.maxWidth),

            // Show this if _selectedValue is null
            items:
                FieldType.values.map((FieldType type) {
                  return DropdownMenuItem<FieldType>(
                    value: type,
                    child: Text(type.label()),
                  );
                }).toList(),
            onChanged: (FieldType? newValue) {
              setState(() {
                _selectedValue = newValue;
              });
              widget.onChanged(newValue);
            },
            // Hide the default dropdown icon, we use our own if needed
            icon: const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  // Helper to build the visual appearance of the button
  Widget _buildButtonChild(BuildContext context, double width) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.size16,
        vertical: Dimens.size10,
      ),
      decoration: BoxDecoration(
        color:
            Theme.of(context).buttonTheme.colorScheme?.primary ??
            Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(Dimens.size8),
      ),
      child: Text(
        // If an item is selected, show its name, otherwise show default button text
        _selectedValue?.label() ?? widget.buttonText,
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
