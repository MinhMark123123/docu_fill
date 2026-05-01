import 'dart:io';

import 'package:archive/archive.dart';
import 'package:docu_fill/core/core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:path/path.dart' as p;

part 'tool_view_model.g.dart';

@BindableViewModel()
class ToolViewModel extends BaseViewModel {
  @Bind()
  late final _isLoading = false.mtd(this);

  Future<void> extractImagesFromDocument() async {
    try {
      // 1. Pick Source File
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['docx', 'xlsx'],
        dialogTitle: AppLang.messagesSelectSourceFile.tr(),
      );

      if (result == null || result.files.single.path == null) return;
      final sourcePath = result.files.single.path!;

      // 2. Pick Destination Folder
      final destPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: AppLang.messagesSelectDestFolder.tr(),
      );

      if (destPath == null) return;

      // 3. Start Extraction
      await loadingGuard(
        Future(() async {
          final bytes = await File(sourcePath).readAsBytes();
          final archive = ZipDecoder().decodeBytes(bytes);

          int count = 0;
          final extension = p.extension(sourcePath).toLowerCase();
          final mediaPath = extension == '.docx' ? 'word/media/' : 'xl/media/';

          for (final file in archive) {
            if (file.isFile && file.name.startsWith(mediaPath)) {
              final fileName = p.basename(file.name);
              final outFile = File(p.join(destPath, fileName));
              await outFile.create(recursive: true);
              await outFile.writeAsBytes(file.content as List<int>);
              count++;
            }
          }

          if (count > 0) {
            showSnackbar(
              AppLang.messagesExtractSuccess.tr(args: [count.toString()]),
            );
          } else {
            showSnackbar("No images found in the selected file.");
          }
        }),
      );
    } catch (e) {
      showSnackbar(AppLang.messagesExtractError.tr(args: [e.toString()]));
    }
  }
}
