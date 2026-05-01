import 'dart:convert';
import 'dart:io';

import 'package:docu_fill/core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'ai_result_selector_view_model.g.dart';

@BindableViewModel()
class AiResultSelectorViewModel extends BaseViewModel {
  @Bind()
  late final _files = <File>[].mtd(this);

  @Bind()
  late final _isLoading = false.mtd(this);

  @override
  void onInitState() {
    super.onInitState();
    loadFiles();
  }

  Future<void> loadFiles() async {
    _isLoading.postValue(true);
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final aiResultsDirPath = p.join(appDocDir.path, "ai_results");
      final aiResultsDir = Directory(aiResultsDirPath);

      if (!await aiResultsDir.exists()) {
        await aiResultsDir.create(recursive: true);
      }

      final filesList =
          await aiResultsDir
              .list()
              .where((e) => e is File && e.path.endsWith('.json'))
              .cast<File>()
              .toList();

      filesList.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      _files.postValue(filesList);
    } catch (e) {
      debugPrint("Error loading AI result files: $e");
    } finally {
      _isLoading.postValue(false);
    }
  }

  Future<Map<String, String>?> selectFile(File file) async {
    try {
      final String content = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);
      return data.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      debugPrint("Error reading AI result file: $e");
      return null;
    }
  }

  Future<void> deleteFile(File file) async {
    try {
      await file.delete();
      await loadFiles();
    } catch (e) {
      debugPrint("Error deleting AI result file: $e");
    }
  }
}
