import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class BoundingBoxClipper extends CustomClipper<Path> {
  final Rect boundingBox;

  BoundingBoxClipper({required this.boundingBox});

  @override
  Path getClip(Size size) {
    // Define the full screen as a path
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Define the bounding box as a path and subtract it
    path.addRect(boundingBox);
    path.fillType =
        PathFillType.evenOdd; // Keep everything outside the bounding box
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true; // Redraw if the bounding box changes
  }
}

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

  // Bounding box width and height ratios
  final double bboxWidthRatio = 0.75; // of screen width
  final double bboxHeightRatio = 0.125; // of screen height

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
      final bboxWidth = screenWidth * bboxWidthRatio;
      final bboxHeight = screenHeight * bboxHeightRatio;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate bounding box dimensions using ratios
    final bboxWidth = screenWidth * bboxWidthRatio;
    final bboxHeight = screenHeight * bboxHeightRatio;

    final boundingBox = Rect.fromCenter(
      center: Offset(screenWidth / 2, screenHeight / 2),
      width: bboxWidth,
      height: bboxHeight,
    );

    return Scaffold(
      backgroundColor: Colors.black, // Black background
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
                // Dimming Overlay with Clear Bounding Box
                Positioned.fill(
                  child: ClipPath(
                    clipper: BoundingBoxClipper(boundingBox: boundingBox),
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),
                // Capture Button
                Positioned(
                  bottom: 50,
                  left: (screenWidth / 2) - 50,
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
