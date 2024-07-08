import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:parking_system/services/api_object_detection_service.dart';
import 'package:parking_system/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:parking_system/providers/parking_providers.dart';
import 'package:web_socket_channel/io.dart';

class AddParkingScreen extends StatefulWidget {
  const AddParkingScreen({super.key});

  @override
  State<AddParkingScreen> createState() => _AddParkingScreenState();
}

class _AddParkingScreenState extends State<AddParkingScreen> {
  final apiService = ApiService('http://localhost:3000');
  final apiObjectDetectionService =
      ApiObjectDetectionService('http://localhost:5000');
  // final channel = IOWebSocketChannel.connect(
  //     'ws://localhost:3000'); // Replace with your server URL

  final TextEditingController numberPlateController = TextEditingController();
  final TextEditingController timeInController = TextEditingController();
  final TextEditingController timeOutController = TextEditingController();
  final TextEditingController cardValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    timeInController.text =
        DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    // channel.stream.listen((message) {
    //   print('Received message from WebSocket: $message');
    //   // Handle message from WebSocket here
    // });
  }

  @override
  void dispose() {
    // channel.sink.close();
    super.dispose();
  }

  // void handleWebSocketMessage(dynamic message) {
  //   try {
  //     Map<String, dynamic> data = jsonDecode(message);
  //     if (data.containsKey('cardValue') && data['cardValue'] != null) {
  //       String cardValue = data['cardValue'];
  //       // Check if the message matches the expected format 'CARD: <value>'
  //       if (cardValue.startsWith('CARD:')) {
  //         // Extract the value after 'CARD: '
  //         String extractedValue = cardValue.substring('CARD: '.length).trim();
  //         setState(() {
  //           cardValueController.text = extractedValue;
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     print('Error parsing WebSocket message: $e');
  //   }
  // }

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
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
                  icon: const Icon(Icons.photo_library),
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
                // Validate and save parking details
                final parkingData = {
                  'numberPlate': numberPlateController.text,
                  'timeIn': timeInController.text,
                  'timeOut': timeOutController.text.isEmpty
                      ? null
                      : timeOutController.text,
                };
                await context
                    .read<ParkingProvider>()
                    .createParking(parkingData);

                // Fetch updated parkings list after creating a new entry
                await context.read<ParkingProvider>().fetchParkings();
                // Navigator.pop(context);
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
                      parking['timeOut'] == null,
                  orElse: () =>
                      {'id': -1}, // Return a default value or empty map
                );

                if (parkingData != null) {
                  // Update timeOut to current time
                  parkingData['timeOut'] =
                      DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
                  print(parkingData['timeOut']);
                  // Calculate money only if timeIn is available
                  if (parkingData['timeIn'] != null) {
                    final timeIn = DateTime.parse(parkingData['timeIn']);
                    final timeOut = DateTime.parse(parkingData['timeOut']!);
                    print(timeIn);

                    print(timeOut);
                    final duration = timeOut.difference(timeIn);
                    final hours = duration.inHours;

                    // Determine the rate based on timeOut
                    int rate = 10000; // Default rate
                    if (timeOut.hour > 17 ||
                        (timeOut.hour == 17 && timeOut.minute > 0)) {
                      rate = 20000; // After 17:00 (5:00 PM)
                    }

                    final money =
                        hours * rate; // Calculate money based on hours and rate

                    // final money = hours * 10; // Assuming $10 per hour

                    // Update parking with timeOut and money calculation
                    await parkingProvider.completeParking(parkingData['id'], {
                      'timeOut': parkingData['timeOut'],
                      'money': money,
                    });

                    // Show dialog with calculated money
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
                    // Handle case where timeIn is null
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error: Time in is not available.'),
                    ));
                  }
                } else {
                  // Handle case where no matching parking entry is found
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'No active parking entry found for this number plate'),
                  ));
                }
              },
              child: const Text('Out'),
            ),
          ],
        ),
      ),
    );
  }
}
