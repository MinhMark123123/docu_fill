import 'dart:async';
import 'dart:ui';

import 'package:docu_fill/core/src/events.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

part 'base_view_model.g.dart';

@BindableViewModel()
class BaseViewModel extends ViewModel {
  @Bind()
  late final _navigatePageEvent = NavigatePageEvent().mtd(this);
  @Bind()
  late final _showSnackbarEvent = ShowSnackbarEvent().mtd(this);
  @Bind()
  late final _showDialogEvent = ShowDialogEvent().mtd(this);

  Future<T?> navigatePage<T>(
    String routeName, {
    Map<String, dynamic>? queryParameters,
    NavigatePageType type = NavigatePageType.push,
  }) async {
    Completer<T?> completer = Completer<T?>();
    _navigatePageEvent.postValue(
      NavigatePageEvent<T>(
        routeName: routeName,
        queryParameters: queryParameters,
        onCompleted: (data) => completer.complete(data),
        type: type,
      ),
    );
    return completer.future;
  }

  Future<void> showSnackbar(String message, {Color? backgroundColor}) async {
    Completer<void> completer = Completer<void>();
    _showSnackbarEvent.postValue(
      ShowSnackbarEvent(
        message: message,
        backgroundColor: backgroundColor,
        onCompleted: (_) => completer.complete(null),
      ),
    );
    return completer.future;
  }

  Future<T?> showDialog<T>({
    String? title,
    String? content,
    List<VoidCallback>? actions,
  }) async {
    Completer<T?> completer = Completer<T?>();
    _showDialogEvent.postValue(
      ShowDialogEvent<T>(
        title: title,
        content: content,
        actions: actions,
        onCompleted: (data) => completer.complete(data),
      ),
    );
    return completer.future;
  }
}
