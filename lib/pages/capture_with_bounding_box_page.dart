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
  bool _isControllerInitialized = false;

  // Bounding box width and height as class-level variables
  double bboxWidth = 200.0;
  double bboxHeight = 200.0;

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
      // Set the flash mode to off
      await _cameraController.setFlashMode(FlashMode.off);
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

      // Crop the captured image using the bounding box dimensions
      final croppedImage = await _cropImage(File(image.path));
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

  Future<File?> _cropImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) return null;

      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      // Scale to the captured image resolution
      final scaleX = originalImage.width / screenWidth;
      final scaleY = originalImage.height / screenHeight;

      // Calculate bounding box position dynamically
      final centerX = screenWidth / 2;
      final centerY = screenHeight / 2;

      final croppedRect = Rect.fromCenter(
        center: Offset(centerX * scaleX, centerY * scaleY),
        width: bboxWidth * scaleX,
        height: bboxHeight * scaleX,
      );

      // Crop the image
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
    // Calculate the bounding box dynamically in the build method
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final boundingBox = Rect.fromCenter(
      center: Offset(screenWidth / 2, screenHeight / 2),
      width: bboxWidth,
      height: bboxHeight,
    );

    return Scaffold(
      body: _isControllerInitialized
          ? Stack(
              children: [
                // Camera Preview that fits within the screen width
                Center(
                  child: AspectRatio(
                    aspectRatio: _cameraController.value.previewSize!.height /
                        _cameraController.value.previewSize!.width,
                    child: CameraPreview(_cameraController),
                  ),
                ),
                // Bounding Box Overlay
                Positioned.fromRect(
                  rect: boundingBox,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                  ),
                ),
                // Capture Button
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
