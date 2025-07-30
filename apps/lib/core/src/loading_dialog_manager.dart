import 'package:flutter/material.dart';

class LoadingDialogManager {
  factory LoadingDialogManager() {
    return _singleton;
  }

  static final LoadingDialogManager _singleton =
      LoadingDialogManager._internal();

  LoadingDialogManager._internal();

  BuildContext? _context;

  void showLoadingDialog(BuildContext context) {
    if (_context != null) return;

    print("----------------> show dialog");
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, _, _) {
        _context = context;
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  void closeLoadingDialog() {
    if (_context == null || _context?.mounted == false) return;
    Navigator.of(_context!).pop();
    _context = null;
  }
}
