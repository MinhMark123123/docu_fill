import 'package:adaptive_layout/adaptive_layout.dart';
import 'package:docu_fill/app.dart';
import 'package:docu_fill/di/repositories_module.dart';
import 'package:docu_fill/di/view_model_module.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'data/src/data_source/isar_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  await IsarDatabase.instance.initialize();
  setupRepositoriesModule();
  setupViewModelModule();
  AdaptiveLayout.setBreakpoints(
    mediumScreenMinWidth: 720,
    largeScreenMinWidth: 1200,
  );
  runApp(const MyApp());
}
