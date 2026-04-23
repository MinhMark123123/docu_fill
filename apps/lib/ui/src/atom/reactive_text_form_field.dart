import 'package:flutter/material.dart';

class ReactiveTextFormField extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;

  const ReactiveTextFormField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.hintText,
    this.maxLines,
    this.minLines,
    this.decoration,
    this.keyboardType,
  });

  @override
  State<ReactiveTextFormField> createState() => _ReactiveTextFormFieldState();
}

class _ReactiveTextFormFieldState extends State<ReactiveTextFormField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant ReactiveTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the controller text if the initialValue prop actually changed
    // and it's different from the current controller text.
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? "";
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      decoration: widget.decoration?.copyWith(hintText: widget.hintText) ??
          InputDecoration(hintText: widget.hintText),
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
    );
  }
}
