import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:sparrow_image_cropper/sparrow_image_cropper.dart';

Future<List<File>> cropImageFiles(
    {required BuildContext context, required double aspectRatio}) async {
  List<File> files = [];
  List<File>? croppedFiles = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ImageCropperWidget(aspectRatio: aspectRatio)));
  if (croppedFiles != null) {
    files = croppedFiles;
  }
  return files;
}

class ImageCropperWidget extends StatefulWidget {
  const ImageCropperWidget({super.key, required this.aspectRatio});
  final double aspectRatio;

  @override
  State<ImageCropperWidget> createState() => _ImageCropperWidgetState();
}

class _ImageCropperWidgetState extends State<ImageCropperWidget> {
  List<File> imageFiles = [];
  List<int> croppedImageFileIndex = [];
  late CropAspectRatioPreset aspectRatioPreset;

  @override
  void initState() {
    _getMultiImageFromGallery();
    _getDoubleToAspectRatio(widget.aspectRatio);
    super.initState();
  }

  Future<void> _getMultiImageFromGallery() async {
    try {
      final List<XFile> xFileList = await ImagePicker().pickMultiImage();
      for (XFile xFile in xFileList) {
        imageFiles.add(File(xFile.path));
      }
    } catch (e) {
      showSnackBar('Error picking image: $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Crop Image'),
        actions: [
          IconButton(
              onPressed: () => _completeCrop(), icon: const Icon(Icons.check))
        ],
      ),
      body: Center(
        child: SizedBox(
          child: imageFiles.isNotEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: size.height * .5,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        scrollDirection: Axis.horizontal,
                        itemCount: imageFiles.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 20),
                        itemBuilder: (context, index) => InkWell(
                          onTap: () async => await _cropImage(index),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: double.infinity,
                                width: size.width * .8,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    border: Border.all(color: Colors.black)),
                                child: Image.file(imageFiles[index],
                                    width: size.width * .8,
                                    fit: BoxFit.fitWidth),
                              ),
                              if (!_alreadyCropped(index))
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  decoration: const BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50))),
                                  child: const Text('Tap to crop',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: InkWell(
                                  onTap: () => _removeFile(index),
                                  child: Icon(Icons.close,
                                      color: Theme.of(context).primaryColor),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 52),
                      child: OutlinedButton(
                          onPressed: () async => await _getMultiImageFromGallery(),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.add,size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Add More',
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          )),
                    )
                  ],
                )
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextButton(
                    onPressed: () async => await _getMultiImageFromGallery(),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.grey, size: 30),
                        Text(
                          'Add Image',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        )
                      ],
                    )),
              ),
        ),
      ),
    );
  }

  Future<void> _cropImage(int index) async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFiles[index].path,
        aspectRatioPresets: [aspectRatioPreset],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Theme.of(context).primaryColor,
            activeControlsWidgetColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
        ),
        iosUiSettings: const IOSUiSettings(title: 'Cropper',
            aspectRatioPickerButtonHidden: true));
    if (croppedFile != null) {
      setState(() {
        if (!croppedImageFileIndex.contains(index)) {
          croppedImageFileIndex.add(index);
        }
        imageFiles[index] = croppedFile;
      });
    }
  }

  void _completeCrop() {
    if (imageFiles.length == croppedImageFileIndex.length) {
      Navigator.pop(context, imageFiles);
    } else {
      showSnackBar('Please crop all image first');
    }
  }

  void _removeFile(int index) => setState(() {
        if (croppedImageFileIndex.contains(index)) {
          croppedImageFileIndex.remove(index);
        }
        imageFiles.removeAt(index);
      });

  bool _alreadyCropped(int index) => croppedImageFileIndex.contains(index);

  void _getDoubleToAspectRatio(double aspectRatio) {
    switch (aspectRatio) {
      case const (1 / 1):
        aspectRatioPreset = CropAspectRatioPreset.square;
      case const (3 / 2):
        aspectRatioPreset = CropAspectRatioPreset.ratio3x2;
      case const (4 / 3):
        aspectRatioPreset = CropAspectRatioPreset.ratio4x3;
      case const (5 / 3):
        aspectRatioPreset = CropAspectRatioPreset.ratio5x3;
      case const (5 / 4):
        aspectRatioPreset = CropAspectRatioPreset.ratio5x4;
      case const (7 / 5):
        aspectRatioPreset = CropAspectRatioPreset.ratio7x5;
      case const (16 / 9):
        aspectRatioPreset = CropAspectRatioPreset.ratio16x9;
      default:
        aspectRatioPreset = CropAspectRatioPreset.original;
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
        content: Text(message,
            style: const TextStyle(color: Colors.white, fontSize: 16))));
  }
}
