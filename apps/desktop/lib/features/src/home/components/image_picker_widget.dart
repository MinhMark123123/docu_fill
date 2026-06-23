import 'dart:io';

import 'package:localization/localization.dart';
import 'package:data/data.dart';
import 'package:design/ui.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final TemplateField imageFiled;
  final String? initialValue;
  final Function(File?) onImageChanged;

  const ImagePickerWidget({
    super.key,
    required this.imageFiled,
    this.initialValue,
    required this.onImageChanged,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initImage();
  }

  @override
  void didUpdateWidget(covariant ImagePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _initImage();
    }
  }

  void _initImage() {
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _image = File(widget.initialValue!);
    } else {
      _image = null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
    widget.onImageChanged(_image);
  }

  void _clearImage() {
    setState(() {
      _image = null;
    });
    widget.onImageChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: Dimens.size150,
        height: Dimens.size150,
        child: Stack(
          children: [
            if (_image == null)
              Positioned(
                bottom: Dimens.size4,
                right: 0,
                left: 0,
                child: Text(
                  AppLang.actionsPickImage.tr(),
                  textAlign: TextAlign.center,
                ),
              ),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: Dimens.size150,
                height: Dimens.size150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    _image == null
                        ? Icon(
                          Icons.add_a_photo,
                          size: Dimens.size50,
                          color: Colors.grey,
                        )
                        : Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            if (_image != null)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  onPressed: _clearImage,
                  icon: Icon(
                    Icons.remove_circle_sharp,
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
