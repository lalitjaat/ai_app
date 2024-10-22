import 'dart:io';
import 'dart:typed_data';

import 'package:ai_app/booleanNotifier.dart';
import 'package:ai_app/examples.dart';
import 'package:ai_app/homePage.dart';
import 'package:ai_app/prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_editor_plus/options.dart';
import 'package:image_picker/image_picker.dart' as imgPicker;
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: ImageEditorr()));
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
            child: Column(
          children: [
            MessangerChatHead(),
            Container(
              height: 10,
              width: 10,
              color: Colors.amber,
              child: const Text("Text"),
            ),
          ],
        ))),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class ImageEditorr extends StatefulWidget {
  const ImageEditorr({super.key});

  @override
  State<ImageEditorr> createState() => _ImageEditorrState();
}

class _ImageEditorrState extends State<ImageEditorr> {
  final imgPicker.ImagePicker _picker = imgPicker.ImagePicker();

  Uint8List? editedImg;

  Future<void> imagePicker() async {
    // Pick an image from the camera
    final imgPicker.XFile? pickedFile =
        await _picker.pickImage(source: imgPicker.ImageSource.camera);

    if (pickedFile != null) {
      // Read the image as bytes
      final Uint8List imageData = await pickedFile.readAsBytes();

      // Navigate to the editedImage screen with the image data

    await  Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageEditor(
            image: imageData,
            cropOption: const CropOption(
              reversible: false,
            ),
          ),
        ),
      );
setState(() {
  editedImg = imageData;
});

await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditedImage(imageData: editedImg as Uint8List,)
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: imagePicker,
                  child: const Text("Upload Image"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditedImage extends StatefulWidget {
  Uint8List imageData;

  EditedImage({super.key, required this.imageData});

  @override
  State<EditedImage> createState() => _EditedImageState();
}

class _EditedImageState extends State<EditedImage> {
  bool? isLoading;
  late Uint8List imageEdited;

  // void loadAsset() async {
  //   isLoading = true;
  //   await ImageEditor.editImage(
  //       image: widget.imageData, imageEditorOption: editorOption);

  //   setState(() {
  //     imageEdited = widget.imageData;

  //     isLoading = false;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    //loadAsset();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: isLoading == true
              ? const CircularProgressIndicator()
              : Image.memory(widget.imageData),
        ),
      ),
    );
  }
}
