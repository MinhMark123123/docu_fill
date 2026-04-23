import 'package:docu_fill/app.dart';
import 'package:docu_fill/di/repositories_module.dart';
import 'package:docu_fill/di/view_model_module.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:window_manager/window_manager.dart';

import 'data/src/data_source/isar_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(1024, 768),
    center: true,
    title: "DocuFill",
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await EasyLocalization.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  await IsarDatabase.instance.initialize();
  setupRepositoriesModule();
  setupViewModelModule();

  runApp(const MyApp());
}
