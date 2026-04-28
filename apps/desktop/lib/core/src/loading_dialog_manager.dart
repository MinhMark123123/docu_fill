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
    // Cancel any pending safety timer when a new task starts
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

    // Start safety timer as a backup whenever a task ends
    _resetSafetyTimer();
  }

  void _updateState() {
    _loadingController.add(_tasks.isNotEmpty);
  }

  void _resetSafetyTimer() {
    _safetyTimer?.cancel();

    // If there are still tasks, we wait 15s to force clear them (safety timeout).
    // If there are NO tasks, we wait 1s and send 'false' again as a backup ping to the UI.
    final duration =
        _tasks.isNotEmpty
            ? const Duration(seconds: 15)
            : const Duration(seconds: 1);

    _safetyTimer = Timer(duration, () {
      if (_tasks.isNotEmpty) {
        debugPrint(
          "LoadingDialogManager: Safety timeout reached after a hide action. Clearing remaining tasks.",
        );
        _tasks.clear();
      } else {
        debugPrint("LoadingDialogManager: Backup sync ping.");
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
              return Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
