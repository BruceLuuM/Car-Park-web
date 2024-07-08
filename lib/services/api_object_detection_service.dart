import 'dart:async';
import 'dart:convert';
import 'dart:io' as io; // For mobile
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart'; // For detecting platform
import 'dart:html' as html; // For web

class ApiObjectDetectionService {
  final String baseUrl;

  ApiObjectDetectionService(this.baseUrl);

  Future<String> detectPlate(dynamic imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl/detect_plate');

      http.BaseRequest request;
      if (kIsWeb) {
        // Web specific multipart request
        request = http.MultipartRequest('POST', uri)
          ..files.add(http.MultipartFile.fromBytes(
            'image',
            imageFile,
            filename: 'image.jpg',
            contentType: MediaType('image', 'jpeg'),
          ));
      } else {
        // Mobile specific multipart request
        request = http.MultipartRequest('POST', uri)
          ..files.add(await http.MultipartFile.fromPath(
            'image',
            (imageFile as io.File).path,
            contentType: MediaType('image', 'jpeg'),
          ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        List<dynamic> results = jsonDecode(response.body);
        // Assuming the first result is the best result
        if (results.isNotEmpty) {
          return results[0]['text'];
        } else {
          throw Exception('No plate detected');
        }
      } else {
        throw Exception('Failed to detect plate: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions
      print('Error: $e');
      return 'error';
    }
  }

  Future<Uint8List> pickImageWeb() async {
    final completer = Completer<Uint8List>();
    final input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();

    input.onChange.listen((e) async {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(input.files!.first);
      reader.onLoadEnd.listen((e) {
        completer.complete(reader.result as Uint8List);
      });
    });

    return completer.future;
  }
}
