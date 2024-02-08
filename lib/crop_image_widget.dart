import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:crop_image/crop_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CropImageWithAspectRatio{

  Future<File?> cropImage({required BuildContext context, required File imageFile, required double aspectRatio})async{
    File? file = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) =>
            CropImageWidget(imageFile: imageFile, aspectRatio: aspectRatio)));
    return file;
  }
}

class CropImageWidget extends StatefulWidget {
  const CropImageWidget(
      {Key? key, required this.imageFile, required this.aspectRatio})
      : super(key: key);
  final File imageFile;
  final double aspectRatio;

  @override
  State<CropImageWidget> createState() => _CropImageWidgetState();
}

class _CropImageWidgetState extends State<CropImageWidget> {
  late CropController controller;
  bool loading = false;

  @override
  void initState() {
    controller = CropController(
      aspectRatio: widget.aspectRatio,
      // defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CropImage(
              controller: controller,
              image: Image.file(widget.imageFile),
              paddingSize: 16.0,
              alwaysMove: true,
              minimumImageSize: 500,
              maximumImageSize: double.infinity,
            ),
          ),
          bottomNavigationBar: _buildButtons(),
        ),
      );

  Widget _buildButtons() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _closeCrop,
          ),
          IconButton(
            icon: const Icon(Icons.rotate_90_degrees_ccw_outlined),
            onPressed: _rotateLeft,
          ),
          IconButton(
            icon: const Icon(Icons.rotate_90_degrees_cw_outlined),
            onPressed: _rotateRight,
          ),
          IconButton(onPressed: _completeCrop, icon: loading
              ? _loadingWidget
              : Icon(Icons.check,color: Theme.of(context).primaryColor),
          )
        ],
      );
  void _closeCrop()=> Navigator.pop(context);

  Future<void> _rotateLeft() async => controller.rotateLeft();

  Future<void> _rotateRight() async => controller.rotateRight();

  Future<void> _completeCrop() async {
    loading = true;
    setState(() {});

    await controller.croppedImage().then((Image image) async {
      ui.Image bitmap = await controller.croppedBitmap();

      var data = await bitmap.toByteData(format: ui.ImageByteFormat.png);
      Uint8List bytes = data!.buffer.asUint8List();

      final temporaryDirectory = await getTemporaryDirectory();
      final directory = Directory('${temporaryDirectory.path}/temp');
      await directory.create(recursive: true);
      final filePath =
          '${directory.path}/cropped_${widget.imageFile.path.split('/').last}';

      final file = await File(filePath).create();
      await file.writeAsBytes(bytes, flush: true).then((value) {
        loading = false;
        setState(() {});
        Navigator.pop(context, value);
      });
    });
  }

  Widget get _loadingWidget => SizedBox(
        height: 25,
        width: 25,
        child: Platform.isAndroid
            ? const CircularProgressIndicator()
            : const CupertinoActivityIndicator(),
      );
}
