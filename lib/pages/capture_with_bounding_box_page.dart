import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class CaptureWithBoundingBoxPage extends StatefulWidget {
  @override
  _CaptureWithBoundingBoxPageState createState() =>
      _CaptureWithBoundingBoxPageState();
}

class _CaptureWithBoundingBoxPageState
    extends State<CaptureWithBoundingBoxPage> {
  late CameraController _cameraController;
  Future<void>? _initializeControllerFuture;
  final GlobalKey _boundingBoxKey = GlobalKey();
  bool _isControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _cameraController =
          CameraController(cameras.first, ResolutionPreset.high);
      _initializeControllerFuture = _cameraController.initialize();
      await _initializeControllerFuture;
      setState(() => _isControllerInitialized = true);
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
      Navigator.pop(context, null);
    }
  }

  Future<void> _captureImage() async {
    if (!_isControllerInitialized) return;
    try {
      final image = await _cameraController.takePicture();
      final renderBox =
          _boundingBoxKey.currentContext!.findRenderObject() as RenderBox;
      final screenArea = renderBox.localToGlobal(Offset.zero) & renderBox.size;

      final croppedImage = await _cropImage(File(image.path), screenArea);
      if (croppedImage != null) {
        final extractedText = await _processImage(croppedImage);
        Navigator.pop(context, extractedText);
      } else {
        Navigator.pop(context, null);
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
      Navigator.pop(context, null);
    }
  }

  Future<File?> _cropImage(File imageFile, Rect screenArea) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) return null;

      // Get the camera preview size
      final previewSize = _cameraController.value.previewSize!;
      final scaleX = originalImage.width / previewSize.width;
      final scaleY = originalImage.height / previewSize.height;

      // Calculate the scaled coordinates of the bounding box
      final croppedRect = Rect.fromLTWH(
        screenArea.left * scaleX,
        screenArea.top * scaleY,
        screenArea.width * scaleX,
        screenArea.height * scaleY,
      );

      // Crop the image to the bounding box
      final cropped = img.copyCrop(
        originalImage,
        x: croppedRect.left.toInt(),
        y: croppedRect.top.toInt(),
        width: croppedRect.width.toInt(),
        height: croppedRect.height.toInt(),
      );

      // Save the cropped image as a temporary file
      final tempDir = await Directory.systemTemp.createTemp('cropped_image');
      final croppedFile = File('${tempDir.path}/cropped_image.jpg')
        ..writeAsBytesSync(img.encodeJpg(cropped));
      return croppedFile;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }

  Future<String> _processImage(File croppedImage) async {
    final inputImage = InputImage.fromFilePath(croppedImage.path);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final recognizedText = await recognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint('Error processing image: $e');
      return '';
    } finally {
      recognizer.close();
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Capture with Bounding Box')),
      body: _isControllerInitialized
          ? Stack(
              children: [
                CameraPreview(_cameraController),
                Positioned(
                  key: _boundingBoxKey,
                  left: 50,
                  top: 150,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 50,
                  left: (MediaQuery.of(context).size.width / 2) - 50,
                  child: ElevatedButton(
                    onPressed: _captureImage,
                    child: Text('Capture'),
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
