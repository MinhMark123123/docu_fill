import 'package:flutter/material.dart';

class LoadingDialogManager {
  factory LoadingDialogManager() {
    return _singleton;
  }

  static final LoadingDialogManager _singleton =
      LoadingDialogManager._internal();

  LoadingDialogManager._internal();

  BuildContext? _context;
  bool _isShowing = false;

  void showLoadingDialog(BuildContext context) {
    if (_isShowing) return;
    _isShowing = true;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (dialogContext, _, _) {
        _context = dialogContext;
        // If closeLoadingDialog was already called while the dialog was opening,
        // we should close it as soon as we have a context.
        if (!_isShowing) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_context != null && _context!.mounted) {
              Navigator.of(_context!).pop();
              _context = null;
            }
          });
        }
        return const Center(child: CircularProgressIndicator());
      },
    ).then((_) {
      // Ensure state is reset when the dialog is dismissed for any reason.
      _isShowing = false;
      _context = null;
    });
  }

  void closeLoadingDialog() {
    _isShowing = false;
    if (_context != null && _context!.mounted) {
      Navigator.of(_context!).pop();
      _context = null;
    }
  }
}

