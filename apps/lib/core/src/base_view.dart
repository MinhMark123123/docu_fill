import 'dart:async';

import 'package:docu_fill/core/src/base_view_model.dart';
import 'package:docu_fill/core/src/events.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

import 'loading_dialog_manager.dart';

abstract class BaseView<T extends BaseViewModel>
    extends DependencyViewModelWidget<T> {
  const BaseView({super.key});

  @override
  void awake(WrapperContext wrapperContext, T viewModel) {
    super.awake(wrapperContext, viewModel);
    final subNavigate = _handlePageNavigator(wrapperContext.context, viewModel);
    final subSnackbar = _handleSnackbar(wrapperContext.context, viewModel);
    final subDialog = _handleDialog(wrapperContext.context, viewModel);
    final subLoading = _handleLoading(wrapperContext.context, viewModel);
    wrapperContext.lifeCycleManager.onDispose(() {
      subNavigate.cancel();
      subSnackbar.cancel();
      subDialog.cancel();
      subLoading.cancel();
      LoadingDialogManager().closeLoadingDialog();
    });
  }

  StreamSubscription<NavigatePageEvent<dynamic>> _handlePageNavigator(
    BuildContext context,
    T viewModel,
  ) {
    final sub = viewModel.navigatePageEvent.asStream().listen((event) {
      if (context.mounted) {
        final path =
            Uri(
              path: event.routeName,
              queryParameters: event.queryParameters,
            ).toString();
        if (event.type == NavigatePageType.push) {
          context.go(path);
        }
        if (event.type == NavigatePageType.replace) {
          context.replace(path);
        }
      }
    });
    return sub;
  }

  StreamSubscription<ShowDialogEvent> _handleDialog(
    BuildContext context,
    T viewModel,
  ) {
    final sub = viewModel.showDialogEvent.asStream().listen((event) {
      if (!context.mounted || event.title == null) return;
      showDialog(
        context: context,
        barrierDismissible: event.actions == null,
        builder: (dialogContext) {
          return alertDialogBuilder(event, dialogContext);
        },
      );
    });
    return sub;
  }

  AlertDialog alertDialogBuilder(
    ShowDialogEvent<dynamic> event,
    BuildContext dialogContext,
  ) {
    return AlertDialog(
      title: Text(event.title!),
      content: Text(event.content ?? ""),
      actions:
          event.actions
              ?.map(
                (e) =>
                    e.isDestructive
                        ? TextButton(
                          child: Text(e.title),
                          onPressed: () => e.onPressed.call(dialogContext),
                        )
                        : ElevatedButton(
                          onPressed: () => e.onPressed.call(dialogContext),
                          child: Text(e.title),
                        ),
              )
              .toList(),
    );
  }

  StreamSubscription<ShowSnackbarEvent> _handleSnackbar(
    BuildContext context,
    T viewModel,
  ) {
    final sub = viewModel.showSnackbarEvent.asStream().listen((event) {
      if (!context.mounted || event.message == null) return;
      final controller = ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(event.message!),
          backgroundColor: event.backgroundColor,
        ),
      );
      controller.closed.then((_) => event.onCompleted?.call(null));
    });
    return sub;
  }

  StreamSubscription<bool> _handleLoading(BuildContext context, T viewModel) {
    final sub = viewModel.showLoading.asStream().listen((isLoading) {
      print("cache event loading $isLoading ${context.mounted}");
      if (context.mounted && isLoading) {
        LoadingDialogManager().showLoadingDialog(context);
      } else if (!isLoading) {
        LoadingDialogManager().closeLoadingDialog();
      }
    });
    return sub;
  }
}
