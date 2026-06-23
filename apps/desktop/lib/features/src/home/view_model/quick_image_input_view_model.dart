import 'package:data/data.dart';
import 'package:docu_fill/core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

part 'quick_image_input_view_model.g.dart';

@BindableViewModel()
class QuickImageInputViewModel extends BaseViewModel {
  final ImagePicker _picker = ImagePicker();

  @Bind()
  late final _paths = <String, String?>{}.mtd(this);

  @Bind()
  late final _imageFields = <TemplateField>[].mtd(this);

  StreamData<Map<String, String?>> get paths => _paths.streamData;
  StreamData<List<TemplateField>> get imageFields => _imageFields.streamData;

  void initialize({
    required List<TemplateField> imageFields,
    required Map<String, String?> currentValues,
  }) {
    _imageFields.postValue(imageFields);
    final initialPaths = <String, String?>{};
    for (var field in imageFields) {
      initialPaths[field.key] = currentValues[field.key];
    }
    _paths.postValue(initialPaths);
  }

  Future<void> pickMultipleImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isEmpty) return;

      final currentPaths = Map<String, String?>.from(_paths.data);
      final fields = _imageFields.data;

      // 1. Identify empty fields and fill them first.
      final List<int> emptyIndices = [];
      for (int i = 0; i < fields.length; i++) {
        final key = fields[i].key;
        if (currentPaths[key] == null || currentPaths[key]!.isEmpty) {
          emptyIndices.add(i);
        }
      }

      int pickedIdx = 0;

      // Fill empty fields first.
      for (final index in emptyIndices) {
        if (pickedIdx >= pickedFiles.length) break;
        currentPaths[fields[index].key] = pickedFiles[pickedIdx].path;
        pickedIdx++;
      }

      // 2. If there are still remaining images, overwrite fields sequentially from the beginning.
      if (pickedIdx < pickedFiles.length) {
        for (int i = 0; i < fields.length; i++) {
          if (pickedIdx >= pickedFiles.length) break;
          currentPaths[fields[i].key] = pickedFiles[pickedIdx].path;
          pickedIdx++;
        }
      }

      _paths.postValue(currentPaths);
    } catch (e) {
      debugPrint("Error picking multiple images: $e");
    }
  }

  void swapImages(int sourceIndex, int targetIndex) {
    final currentPaths = Map<String, String?>.from(_paths.data);
    final fields = _imageFields.data;

    final sourceKey = fields[sourceIndex].key;
    final targetKey = fields[targetIndex].key;

    final temp = currentPaths[sourceKey];
    currentPaths[sourceKey] = currentPaths[targetKey];
    currentPaths[targetKey] = temp;

    _paths.postValue(currentPaths);
  }

  void clearAllImages() {
    final currentPaths = Map<String, String?>.from(_paths.data);
    for (var key in currentPaths.keys) {
      currentPaths[key] = null;
    }
    _paths.postValue(currentPaths);
  }

  void clearFieldImage(String key) {
    final currentPaths = Map<String, String?>.from(_paths.data);
    currentPaths[key] = null;
    _paths.postValue(currentPaths);
  }

  Future<void> pickSingleImageForField(String key) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final currentPaths = Map<String, String?>.from(_paths.data);
        currentPaths[key] = pickedFile.path;
        _paths.postValue(currentPaths);
      }
    } catch (e) {
      debugPrint("Error picking single image: $e");
    }
  }
}
