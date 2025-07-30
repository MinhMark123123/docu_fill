import 'package:docu_fill/ui/src/methodology/tokens/dimens.dart';
import 'package:flutter/material.dart';

class OutlineDropdownButton extends StatefulWidget {
  final List<String> items;
  final String? initialValue; // The initially selected string
  final ValueChanged<String?> onSelected; // Callback when an item is selected
  final String hintText; // Text to display when nothing is selected
  final IconData? leadingIcon; // Optional icon on the left of the text
  final EdgeInsetsGeometry? padding;
  final OutlinedBorder? shape;
  final Color? focusColor;
  final Color? borderColor; // Optional: To customize border color
  final double? borderWidth; // Optional: To customize border width

  const OutlineDropdownButton({
    super.key,
    required this.items,
    this.initialValue,
    required this.onSelected,
    this.hintText = "Select an option",
    this.leadingIcon,
    this.padding,
    this.shape,
    this.focusColor,
    this.borderColor,
    this.borderWidth,
  });

  @override
  State<OutlineDropdownButton> createState() => _OutlineDropdownButtonState();
}

class _OutlineDropdownButtonState extends State<OutlineDropdownButton> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    // Ensure initialValue is within items, otherwise don't set it.
    if (widget.initialValue != null &&
        widget.items.contains(widget.initialValue)) {
      _selectedValue = widget.initialValue;
    } else if (widget.items.isNotEmpty && widget.initialValue != null) {
      // Optional: Handle if initialValue is provided but not in items.
      // Maybe select the first item or log a warning. For now, we'll ignore it
      // if it's not a valid choice from the list.
      print(
        "Warning: initialValue '${widget.initialValue}' not found in items list.",
      );
    }
  }

  @override
  void didUpdateWidget(OutlineDropdownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      if (widget.initialValue != null &&
          widget.items.contains(widget.initialValue)) {
        setState(() {
          _selectedValue = widget.initialValue;
        });
      } else if (widget.initialValue == null) {
        setState(() {
          _selectedValue = null;
        });
      }
    }
    // If items list changes and current _selectedValue is no longer valid
    if (!widget.items.contains(_selectedValue) && _selectedValue != null) {
      setState(() {
        _selectedValue = null; // Reset or pick first valid item
        widget.onSelected(null); // Notify parent
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    // Use custom border color if provided, else theme's default outline color
    Color effectiveBorderColor =
        widget.borderColor ?? theme.colorScheme.outline;
    double effectiveBorderWidth = widget.borderWidth ?? 1.0;

    return PopupMenuButton<String>(
      initialValue: _selectedValue,
      onSelected: (String value) {
        setState(() {
          _selectedValue = value;
        });
        widget.onSelected(value);
      },
      itemBuilder: (BuildContext context) {
        return widget.items.map((String item) {
          return PopupMenuItem<String>(value: item, child: Text(item));
        }).toList();
      },
      // This child is our custom outlined button appearance
      child: Material(
        // Using Material to get InkWell effects if needed
        color: Colors.transparent,
        // Ensure button color doesn't obscure outline
        child: InkWell(
          // To provide visual feedback on tap, like InkWell
          borderRadius:
              (widget.shape is RoundedRectangleBorder &&
                      (widget.shape as RoundedRectangleBorder).borderRadius !=
                          BorderRadius.zero)
                  ? (widget.shape as RoundedRectangleBorder).borderRadius
                      .resolve(Directionality.of(context))
                  : Dimens.radii.borderSmall(),
          // Default border radius for InkWell splash
          focusColor: widget.focusColor ?? theme.focusColor,
          onTap: null,
          // PopupMenuButton handles its own tap, InkWell is for visual feedback
          child: Container(
            padding:
                widget.padding ??
                EdgeInsets.symmetric(
                  horizontal: Dimens.size16,
                  vertical: Dimens.size12,
                ),
            decoration: BoxDecoration(
              border: Border.all(
                color: effectiveBorderColor,
                width: effectiveBorderWidth,
              ),
              borderRadius:
                  (widget.shape is RoundedRectangleBorder &&
                          (widget.shape as RoundedRectangleBorder)
                                  .borderRadius !=
                              BorderRadius.zero)
                      ? (widget.shape as RoundedRectangleBorder).borderRadius
                          .resolve(Directionality.of(context))
                      : Dimens.radii
                          .borderSmall(), // Default border radius for Container
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Keep button size to its content
              children: <Widget>[
                if (widget.leadingIcon != null) ...[
                  Icon(
                    widget.leadingIcon,
                    size: Dimens.size20, // Adjust as needed
                    color:
                        _selectedValue != null
                            ? theme.textTheme.bodyLarge?.color
                            : theme.hintColor,
                  ),
                  Dimens.spacing.horizontal(Dimens.size8),
                ],
                Expanded(
                  child: Text(
                    _selectedValue ?? widget.hintText,
                    style:
                        _selectedValue != null
                            ? theme.textTheme.titleMedium
                            : theme.textTheme.titleMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Dimens.spacing.horizontal(Dimens.size8),
                // Space before the dropdown arrow
                Icon(
                  Icons.arrow_drop_down,
                  color:
                      _selectedValue != null
                          ? theme.textTheme.bodyLarge?.color
                          : theme.hintColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
