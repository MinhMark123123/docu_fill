import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';

class UploadLayoutMobile extends StatelessWidget {
  const UploadLayoutMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(AppLang.actionsUpload.tr())));
  }
}
