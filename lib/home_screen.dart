import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper_text/app_media_service.dart';
import 'package:image_cropper_text/crop_image_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? originalImageFile;
  File? croppedImageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Original Image:'),
                if (originalImageFile != null)
                  Image.file(originalImageFile!,
                      width: double.infinity, fit: BoxFit.fitWidth),
                const SizedBox(height: 20),
                const Text('Cropped Image:'),
                if (croppedImageFile != null)
                  Image.file(croppedImageFile!,
                      width: double.infinity, fit: BoxFit.fitWidth),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // await getImageButtonOnTap();
                  },
                  child: const Text('Get Image'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await getMultipleImageButtonOnTap();
                  },
                  child: const Text('Get Multiple Image'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> getImageButtonOnTap() async {
  //   await AppMediaService().getImageFromGallery().then((file) async {
  //     if (file != null) {
  //       originalImageFile = file;
  //       setState(() {});
  //       var cropFile = await CropImageWithAspectRatio().cropImage(
  //           context: context,
  //           imageFile: originalImageFile!,
  //           aspectRatio: 4/3);
  //       if (cropFile != null) {
  //         debugPrint('Returned Image::::::: ${cropFile.path}');
  //         croppedImageFile = cropFile;
  //         setState(() {});
  //       }
  //     }
  //   });
  // }

  Future<void> getMultipleImageButtonOnTap() async {
    await AppMediaService().getMultiImageFromGallery(context).then((files) async {
      if (files != null) {
        setState(() {});
        debugPrint('${files.length}');
        var cropFile = await CropImageWithAspectRatio().cropImage(
            context: context,
            imageFiles: files,
            aspectRatio: 4/3);
        if (cropFile != null) {
          debugPrint('Returned Image::::::: ${cropFile.path}');
          croppedImageFile = cropFile;
          setState(() {});
        }
      }
    });
  }
}
