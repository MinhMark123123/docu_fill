import 'dart:async';

import 'package:flutter/material.dart';

class LoadingDialogManager {
  factory LoadingDialogManager() => _singleton;

  static final LoadingDialogManager _singleton =
      LoadingDialogManager._internal();

  LoadingDialogManager._internal();

  final _loadingController = StreamController<bool>.broadcast();
  Stream<bool> get loadingStream => _loadingController.stream;

  final Set<String> _tasks = {};
  Timer? _safetyTimer;

  void showLoading({String? taskId}) {
    _safetyTimer?.cancel();
    final id = taskId ?? DateTime.now().microsecondsSinceEpoch.toString();
    _tasks.add(id);
    _updateState();
  }

  void hideLoading({String? taskId}) {
    if (taskId != null) {
      _tasks.remove(taskId);
    } else if (_tasks.isNotEmpty) {
      _tasks.remove(_tasks.last);
    }
    _updateState();
    _resetSafetyTimer();
  }

  void clearTasksByPrefix(String prefix) {
    _tasks.removeWhere((id) => id.startsWith(prefix));
    _updateState();
    _resetSafetyTimer();
  }

  void _updateState() {
    _loadingController.add(_tasks.isNotEmpty);
  }

  void _resetSafetyTimer() {
    _safetyTimer?.cancel();

    // Safety backup:
    // If tasks are still present, wait 15s to force clear (emergency).
    // If no tasks, wait 1s for a backup 'false' sync ping.
    final duration =
        _tasks.isNotEmpty
            ? const Duration(seconds: 30)
            : const Duration(seconds: 1);

    _safetyTimer = Timer(duration, () {
      if (_tasks.isNotEmpty) {
        debugPrint(
          "LoadingDialogManager: Safety timeout reached. Clearing tasks.",
        );
        _tasks.clear();
      }
      _updateState();
    });
  }

  void dispose() {
    _loadingController.close();
    _safetyTimer?.cancel();
  }
}

class LoadingWrapper extends StatefulWidget {
  final Widget child;

  const LoadingWrapper({super.key, required this.child});

  @override
  State<LoadingWrapper> createState() => _LoadingWrapperState();
}

class _LoadingWrapperState extends State<LoadingWrapper> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        StreamBuilder<bool>(
          stream: LoadingDialogManager().loadingStream,
          initialData: false,
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return AbsorbPointer(
                child: Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
