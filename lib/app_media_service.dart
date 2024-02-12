import 'dart:io';
import 'package:flutter/Material.dart';
import 'package:image_cropper_text/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class AppMediaService {
  Future<File?> getImageFromCamera() async {
    File? file;
    final bool permission = await AppPermissionHandler().cameraPermission();
    if (!permission) {
      return null;
    }
    try {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        file = File(image.path);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
    return file;
  }

  Future<File?> getImageFromGallery() async {
    File? file;
    final bool permission = await AppPermissionHandler().galleryPermission();
    if (!permission) {
      return null;
    }
    try {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        file = File(image.path);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
    return file;
  }

  Future<List<File>> getMultiImageFromGallery(BuildContext context) async {
    List<File> fileList = [];
    try {
      final List<XFile> xFileList = await ImagePicker().pickMultiImage();
      for(XFile xFile in xFileList){
        fileList.add(File(xFile.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    return fileList;
  }
}
