import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;

class VideoCameraScreen extends StatefulWidget {
  @override
  _VideoCameraScreenState createState() => _VideoCameraScreenState();
}

class _VideoCameraScreenState extends State<VideoCameraScreen> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller!.initialize();
  }

  Future<void> _captureFrame() async {
    try {
      await _initializeControllerFuture;

      final image = await _controller!.takePicture();
      final imageBytes = await image.readAsBytes();

      final plateNumber = await _detectPlate(imageBytes);

      setState(() {
        numberPlateController.text = plateNumber;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<String> _detectPlate(Uint8List imageBytes) async {
    final response = await http.post(
      Uri.parse('YOUR_API_ENDPOINT'),
      headers: {'Content-Type': 'application/octet-stream'},
      body: imageBytes,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to detect plate number');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  final TextEditingController numberPlateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Parking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: <Widget>[
                      CameraPreview(_controller!),
                      Transform.scale(
                        scale: -1.0,
                        alignment: Alignment.center,
                        child: CameraPreview(_controller!),
                      ),
                    ],
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: numberPlateController,
                    decoration:
                        const InputDecoration(labelText: 'Number Plate'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _captureFrame,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
