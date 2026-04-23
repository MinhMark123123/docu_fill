import 'dart:io';

import 'package:docu_fill/core/core.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:path_provider/path_provider.dart';

part 'log_detail_view_model.g.dart';

@BindableViewModel()
class LogDetailViewModel extends BaseViewModel {
  @Bind()
  late final _content = "".mtd(this);

  Future<void> loadLogDetail(String fileName) async {
    if (fileName.isEmpty) return;
    await loadingGuard(Future(() async {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = "${directory.path}/api_logs/$fileName";
        final file = File(filePath);

        if (await file.exists()) {
          final text = await file.readAsString();
          _content.postValue(text);
        } else {
          _content.postValue("File not found: $fileName");
        }
      } catch (e) {
        _content.postValue("Error reading log file: $e");
      }
    }));
  }
}
