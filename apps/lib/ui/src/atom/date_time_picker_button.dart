import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';

class DateTimePickerButton extends StatefulWidget {
  final ValueChanged<DateTime?> onDateTimeChanged;
  final DateTime? initialDateTime;
  final String? buttonText;
  final IconData? buttonIcon;

  const DateTimePickerButton({
    super.key,
    required this.onDateTimeChanged,
    this.initialDateTime,
    this.buttonText,
    this.buttonIcon,
  });

  @override
  State<DateTimePickerButton> createState() => _DateTimePickerButtonState();
}

class _DateTimePickerButtonState extends State<DateTimePickerButton> {
  DateTime? _selectedDateTime;

  String get dateFormat => 'MMM d, yyyy - hh:mm a';

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime;
  }

  // Update if the initialDateTime prop changes
  @override
  void didUpdateWidget(covariant DateTimePickerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDateTime != oldWidget.initialDateTime) {
      setState(() {
        _selectedDateTime = widget.initialDateTime;
      });
    }
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final DateTime now = DateTime.now();
    DateTime? initialDateForPicker = _selectedDateTime ?? now;

    // Ensure initialDateForPicker is not in the past if you have such constraints,
    // or adjust as needed for your specific use case.
    // For `showDatePicker`, firstDate should not be after initialDate.
    DateTime firstDatePickerDate = DateTime(
      now.year - 5,
    ); // Allow selecting dates from 5 years ago
    if (now.isBefore(firstDatePickerDate)) {
      // Should not happen with now.year - 5
      firstDatePickerDate = now;
    }
    if (initialDateForPicker.isBefore(firstDatePickerDate)) {
      initialDateForPicker = firstDatePickerDate;
    }

    // 1. Pick Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.input,
      initialDate: initialDateForPicker,
      firstDate: firstDatePickerDate,
      // Or your specific earliest selectable date
      lastDate: DateTime(
        now.year + 5,
      ), // Or your specific latest selectable date
    );

    if (pickedDate == null) {
      // User cancelled date picking
      return;
    }

    // 2. Pick Time (initialize with current time if no date was previously selected,
    // or use the time from the previously selected DateTime)
    final TimeOfDay initialTimeForPicker =
        _selectedDateTime != null
            ? TimeOfDay.fromDateTime(_selectedDateTime!)
            : TimeOfDay.fromDateTime(
              now,
            ); // Crucially, use current time for time picker start
    if (!context.mounted) return;
    /*final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTimeForPicker,
    );*/

    // 3. Combine date and time
    final newSelectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
    );

    setState(() {
      _selectedDateTime = newSelectedDateTime;
    });
    widget.onDateTimeChanged(_selectedDateTime);
  }

  @override
  Widget build(BuildContext context) {
    // Determine the text to display on the button
    String displayDateTimeText;
    if (_selectedDateTime != null) {
      // Format the selected DateTime for display
      displayDateTimeText = DateFormat(dateFormat).format(_selectedDateTime!);
    } else {
      displayDateTimeText =
          widget.buttonText ?? AppLang.actionsSelectDateTime.tr();
    }

    return ElevatedButton.icon(
      icon:
          widget.buttonIcon != null
              ? Icon(widget.buttonIcon)
              : const Icon(Icons.calendar_today),
      label: Text(displayDateTimeText),
      onPressed: () => _pickDateTime(context),
    );
  }
}
