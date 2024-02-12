import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper_text/image_cropper_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<File> croppedFiles = [];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await getMultipleImageButtonOnTap();
                },
                child: const Text('Add Post'),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: croppedFiles.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 20),
                  itemBuilder: (context, index) => Container(
                    height: size.width * .9,
                    width: size.width * .9,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black)
                    ),
                    child: Image.file(croppedFiles[index],
                        width: size.width * .8, fit: BoxFit.fitWidth),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getMultipleImageButtonOnTap() async {
    croppedFiles = await cropImageFiles(context: context, aspectRatio: (4/3));
    debugPrint('Cropped Files: ${croppedFiles.length}');
    setState(() {});
  }
}
