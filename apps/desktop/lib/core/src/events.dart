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
  final List<String>? options;

  ShowDialogEvent({
    this.title,
    this.content,
    super.onCompleted,
    this.actions,
    this.options,
  });

  ShowDialogEvent<T> copyWith({
    String? title,
    String? content,
    List<DialogAction>? actions,
    List<String>? options,
    Function(T? completeData)? onCompleted,
  }) {
    return ShowDialogEvent<T>(
      title: title ?? this.title,
      content: content ?? this.content,
      actions: actions ?? this.actions,
      options: options ?? this.options,
      onCompleted: onCompleted ?? this.onCompleted,
    );
  }
}

class LoadingEvent {
  final String id;
  final bool show;

  LoadingEvent({required this.id, required this.show});
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
