import 'package:flutter/material.dart';

abstract class UiActionEvent<T> {
  final Function(T? completeData)? onCompleted;

  UiActionEvent({this.onCompleted});
} // Base class for all UI actions

class NavigatePageEvent<T> extends UiActionEvent<T> {
  final String? routeName;
  final Map<String, dynamic>? queryParameters;
  final NavigatePageType type;

  NavigatePageEvent({
    this.routeName,
    this.queryParameters,
    super.onCompleted,
    this.type = NavigatePageType.push,
  });
}

enum NavigatePageType { push, replace, pop, popUntil }

class ShowSnackbarEvent extends UiActionEvent<void> {
  final String? message;
  final Color? backgroundColor; // Optional: customize snackbar
  ShowSnackbarEvent({this.message, this.backgroundColor, super.onCompleted});
}

class ShowDialogEvent<T> extends UiActionEvent<T> {
  final String? title;
  final String? content;
  final List<DialogAction>? actions;

  // Add other dialog properties as needed (e.g., action buttons)
  ShowDialogEvent({this.title, this.content, super.onCompleted, this.actions});
}

class DialogAction {
  final String title;
  final Function(BuildContext context) onPressed;
  final bool isDestructive;

  DialogAction({
    required this.title,
    required this.onPressed,
    this.isDestructive = false,
  });
}
