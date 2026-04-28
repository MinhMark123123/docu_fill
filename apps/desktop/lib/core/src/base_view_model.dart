import 'dart:async';

import 'package:docu_fill/core/src/events.dart';
import 'package:flutter/cupertino.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

part 'base_view_model.g.dart';

@BindableViewModel()
class BaseViewModel extends ViewModel {
  @Bind()
  late final _loadingEvent = LoadingEvent(id: '', show: false).mtd(this);

  StreamData<LoadingEvent> get loadingEvent => _loadingEvent.streamData;

  @Bind()
  late final _navigatePageEvent = NavigatePageEvent().mtd(this);
  @Bind()
  late final _showSnackbarEvent = ShowSnackbarEvent().mtd(this);
  @Bind()
  late final _showDialogEvent = ShowDialogEvent().mtd(this);

  @override
  void onInitState() {
    debugPrint("====> $runtimeType $hashCode onInitState");
    super.onInitState();
  }

  @override
  void onResume() {
    debugPrint("====> $runtimeType $hashCode onResume");
    super.onResume();
    //
  }

  @override
  void onPause() {
    debugPrint("====> $runtimeType $hashCode onPause");
    super.onPause();
  }

  final Set<String> _disposeSensitiveTasks = {};

  @override
  void onDispose() {
    debugPrint("====> $runtimeType $hashCode onDispose");
    for (final taskId in _disposeSensitiveTasks) {
      _loadingEvent.postValue(LoadingEvent(id: taskId, show: false));
    }
    _disposeSensitiveTasks.clear();
    super.onDispose();
  }

  Future<T?> navigatePage<T>(
    String routeName, {
    Map<String, dynamic>? queryParameters,
    NavigatePageType type = NavigatePageType.push,
  }) async {
    Completer<T?> completer = Completer<T?>();
    _navigatePageEvent.postValue(
      NavigatePageEvent<dynamic>(
        routeName: routeName,
        queryParameters: queryParameters,
        onCompleted: (data) => completer.complete(data as T?),
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

  Future<T?> showAppAlertDialog<T>({
    String? title,
    String? content,
    required List<DialogAction> actions,
  }) async {
    Completer<T?> completer = Completer<T?>();
    _showDialogEvent.postValue(
      ShowDialogEvent<dynamic>(
        title: title,
        content: content,
        actions: actions,
        onCompleted: (data) => completer.complete(data as T?),
      ),
    );
    return completer.future;
  }

  Future<T?> showAppRawEventAlertDialog<T>({
    required ShowDialogEvent<dynamic> event,
  }) async {
    Completer<T?> completer = Completer<T?>();
    _showDialogEvent.postValue(
      event.copyWith(onCompleted: (data) => completer.complete(data as T?)),
    );
    return completer.future;
  }

  Future<int?> showSelectionDialog({
    String? title,
    required List<String> options,
  }) async {
    Completer<int?> completer = Completer<int?>();
    _showDialogEvent.postValue(
      ShowDialogEvent<dynamic>(
        title: title,
        options: options,
        onCompleted: (data) => completer.complete(data as int?),
      ),
    );
    return completer.future;
  }

  Future<T> loadingGuard<T>(
    Future<T> future, {
    bool hideOnDispose = true,
  }) async {
    final taskId = "task_${hashCode}_${DateTime.now().microsecondsSinceEpoch}";
    if (hideOnDispose) _disposeSensitiveTasks.add(taskId);

    _loadingEvent.postValue(LoadingEvent(id: taskId, show: true));
    try {
      return await future;
    } finally {
      if (hideOnDispose) _disposeSensitiveTasks.remove(taskId);
      _loadingEvent.postValue(LoadingEvent(id: taskId, show: false));
    }
  }
}
