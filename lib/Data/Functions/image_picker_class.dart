import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<dynamic> pickImage({
  ImageSource? source,
  bool? needPath = false,
  required BuildContext context,
}) async {
  final picker = ImagePicker();

  String path = '';
  File? pathFile;

  try {
    final getImage = await picker.pickImage(
        source: source!, preferredCameraDevice: CameraDevice.rear);

    if (getImage != null) {
      path = getImage.path;
      pathFile = File(getImage.path);
    } else {
      path = '';
    }
  } catch (e) {
    log(e.toString());
  }

  if (needPath == true) {
    return pathFile;
  } else {
    return path;
  }
}

Future<List<File>> pickMaltiImage({
  required BuildContext context,
}) async {
  final picker = ImagePicker();

  List<File> paths = [];

  try {
    final getImage = await picker.pickMultiImage();

    if (getImage.isNotEmpty) {
      for (int i = 0; i < getImage.length; i++) {
        paths.add(File(getImage[i].path));
      }
    } else {
      paths = [];
    }
  } catch (e) {
    log(e.toString());
  }

  return paths;
}
