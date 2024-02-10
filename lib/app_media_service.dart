import 'dart:io';
import 'package:flutter/Material.dart';
import 'package:image_cropper_text/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<List<File>?> getMultiImageFromGallery(BuildContext context) async {
    List<File> files = [];
    List<Asset> images=[];
    try {
      final List<Asset> resultList = await MultiImagePicker.pickImages(
        selectedAssets: images,
        iosOptions: IOSOptions(
          doneButton: UIBarButtonItem(title: 'Confirm', tintColor: Theme.of(context).colorScheme.primary),
          cancelButton: UIBarButtonItem(title: 'Cancel', tintColor: Theme.of(context).colorScheme.primary),
          albumButtonColor: Theme.of(context).colorScheme.primary,
        ),
        androidOptions: const AndroidOptions(
          maxImages: 1000,
          actionBarTitle: "Select Images",
          allViewTitle: "All Photos",
          useDetailsView: false,
        ),
      );
      for (Asset asset in resultList) {
        final byteData = await asset.getByteData();
        final buffer = byteData.buffer.asUint8List();
        final directory = await getTemporaryDirectory();
        final String fileName = asset.name;
        final File file = File('${directory.path}/$fileName');
        await file.writeAsBytes(buffer);
        files.add(file);
      }
      // return files;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
    return files;
  }
}
