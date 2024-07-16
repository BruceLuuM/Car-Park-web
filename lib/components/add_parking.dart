import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:parking_system/services/api_object_detection_service.dart';
import 'package:parking_system/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:parking_system/providers/parking_providers.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class AddParkingScreen extends StatefulWidget {
  final Function? onUpdate; // Callback function to notify parent

  const AddParkingScreen({
    super.key,
    this.onUpdate,
  });

  @override
  State<AddParkingScreen> createState() => _AddParkingScreenState();
}

class _AddParkingScreenState extends State<AddParkingScreen> {
  final apiService = ApiService('http://localhost:3000');
  final apiObjectDetectionService =
      ApiObjectDetectionService('http://localhost:5000');

  final TextEditingController numberPlateController = TextEditingController();
  final TextEditingController timeInController = TextEditingController();
  final TextEditingController timeOutController = TextEditingController();
  final TextEditingController cardValueController = TextEditingController();

  CameraController? _cameraController;
  late Future<void> _initializeControllerFuture;

  late IO.Socket _socket;

  @override
  void initState() {
    super.initState();
    timeInController.text =
        DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    _initializeCamera();
    _connectSocket();
    setState(() {
      cardValueController.text = '';
    });
  }

  void _connectSocket() {
    _socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket.connect();

    _socket.onConnect((_) {
      print('Connected to the server');
    });

    _socket.on('cardID', (data) {
      print(data);
      setState(() {
        cardValueController.text = data;
      });
    });

    _socket.onDisconnect((_) {
      print('Disconnected from the server');
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _captureFrame() async {
    try {
      await _initializeControllerFuture;

      final image = await _cameraController!.takePicture();
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
    // final Uint8List imageBytes = await apiObjectDetectionService.pickImageWeb();
    String plateNumber =
        await apiObjectDetectionService.detectPlate(imageBytes);
    // setState(() {
    //   numberPlateController.text = plateNumber;
    // });

    // final response = await http.post(
    //   Uri.parse(
    //       'http://localhost:5000/detect_plate'), // replace with your endpoint
    //   headers: {'Content-Type': 'application/octet-stream'},
    //   body: imageBytes,
    // );

    // if (response.statusCode == 200) {
    return plateNumber;
    // } else {
    //   throw Exception('Failed to detect plate number');
    // }
  }

  @override
  void dispose() {
    _cameraController?.dispose();

    super.dispose();
  }

  Future<void> _selectImage() async {
    final Uint8List imageBytes = await apiObjectDetectionService.pickImageWeb();
    String plateNumber =
        await apiObjectDetectionService.detectPlate(imageBytes);
    setState(() {
      numberPlateController.text = plateNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Parking'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                        // CameraPreview(_cameraController!),
                        Transform(
                          alignment: Alignment.center,
                          transform:
                              Matrix4.rotationY(pi), // Apply vertical flip
                          child: CameraPreview(_cameraController!),
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
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _selectImage,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: cardValueController,
                decoration: const InputDecoration(
                  labelText: 'Card Id',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: timeInController,
                decoration: const InputDecoration(labelText: 'Time In'),
                readOnly: true,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: timeOutController,
                decoration: const InputDecoration(labelText: 'Time Out'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final parkingData = {
                    'numberPlate': numberPlateController.text,
                    'cardID': cardValueController.text,
                    'timeIn': timeInController.text,
                    'timeOut': timeOutController.text.isEmpty
                        ? null
                        : timeOutController.text,
                  };
                  await context
                      .read<ParkingProvider>()
                      .createParking(parkingData);

                  await context.read<ParkingProvider>().fetchParkings();

                  widget.onUpdate?.call();
                },
                child: const Text('In'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final parkingProvider = context.read<ParkingProvider>();
                  final parkingData = parkingProvider.parkings.firstWhere(
                    (parking) =>
                        parking['numberPlate'] == numberPlateController.text &&
                        parking['card']['cardId'] == cardValueController.text &&
                        parking['timeOut'] == null,
                    orElse: () => {'id': -1},
                  );
                  if (parkingData['id'] == -1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Information not correct'),
                      ),
                    );
                    return; // Stop execution here
                  }

                  if (parkingData != null && parkingData['id'] != -1) {
                    parkingData['timeOut'] =
                        DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

                    if (parkingData['timeIn'] != null) {
                      final timeIn = DateTime.parse(parkingData['timeIn']);
                      final timeOut = DateTime.parse(parkingData['timeOut']!);
                      final duration = timeOut.difference(timeIn);
                      final hours = duration.inHours;
                      // pp tính tiền
                      int rate = 10000;
                      if (timeOut.hour > 17 ||
                          (timeOut.hour == 17 && timeOut.minute > 0)) {
                        rate = 20000;
                      }

                      final money = hours * rate;

                      await parkingProvider.completeParking(parkingData['id'], {
                        'card': {'cardId': parkingData['cardId']},
                        'numberPlate': parkingData['numberPlate'],
                        'timeOut': parkingData['timeOut'],
                        'money': money,
                      });

                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Calculate'),
                          content: Text('Total: \$ $money đ'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Error: Time in is not available.'),
                      ));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'No active parking entry found for this number plate'),
                    ));
                  }

                  widget.onUpdate?.call();
                },
                child: const Text('Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
