import 'dart:async';
import 'package:http/http.dart' as http;

class MockApiService {
  final String baseUrl;

  MockApiService(this.baseUrl);

  Future<Map<String, dynamic>> login(String username, String password) async {
    // Simulate a successful login response
    await Future.delayed(Duration(seconds: 1));
    return {'token': 'mock-token'};
  }

  Future<Map<String, dynamic>> signup(
      {required String password,
      required String username,
      required String fullName,
      required String email,
      String? phone}) async {
    // Simulate a successful login response
    await Future.delayed(Duration(seconds: 1));
    return {'token': 'mock-token'};
  }

  Future<void> logout(String token) async {
    // Simulate a logout response
    await Future.delayed(Duration(seconds: 1));
  }

  Future<Map<String, dynamic>> createCard(Map<String, dynamic> cardData) async {
    // Simulate creating a card
    await Future.delayed(Duration(seconds: 1));
    return cardData;
  }

  Future<Map<String, dynamic>> updateCard(
      int id, Map<String, dynamic> cardData) async {
    // Simulate updating a card
    await Future.delayed(Duration(seconds: 1));
    return cardData;
  }

  Future<Map<String, dynamic>> createParking(
      Map<String, dynamic> parkingData) async {
    // Simulate creating a parking entry
    await Future.delayed(Duration(seconds: 1));
    return parkingData;
  }

  Future<Map<String, dynamic>> completeParking(
      int id, Map<String, dynamic> parkingData) async {
    // Simulate completing a parking entry
    await Future.delayed(Duration(seconds: 1));
    return parkingData;
  }

  Future<List<Map<String, dynamic>>> getParkings() async {
    // Simulate fetching parking entries
    await Future.delayed(Duration(seconds: 1));
    return [
      {
        'id': 1,
        'cardId': 'card-123',
        'numberPlate': 'ABC123',
        'timeIn': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
        'timeOut': null,
      },
      {
        'id': 2,
        'cardId': 'card-456',
        'numberPlate': 'DEF456',
        'timeIn': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
        'timeOut':
            DateTime.now().subtract(Duration(minutes: 30)).toIso8601String(),
      },
    ];
  }

  Future<Map<String, dynamic>> getParking(int id) async {
    // Simulate fetching a single parking entry
    await Future.delayed(Duration(seconds: 1));
    return {
      'id': id,
      'cardId': 'card-123',
      'numberPlate': 'ABC123',
      'timeIn': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
      'timeOut': null,
    };
  }

  Future<String> captureFrameAndRetrievePlateNumber() async {
    // Replace with your logic to capture frame from streaming video
    // For demonstration, sending a dummy image
    String imageUrl = 'https://example.com/streaming-video-frame';

    // Replace with your API endpoint for plate recognition
    String apiEndpoint = 'https://example.com/recognize-plate';

    try {
      // Simulate capturing a frame from streaming video
      // Replace with actual logic to capture frame and convert to bytes
      // For example, using http package to send POST request
      var response = await http
          .post(Uri.parse(apiEndpoint), body: {'image_url': imageUrl});

      if (response.statusCode == 200) {
        // Assuming API returns plate number in JSON response
        return response.body;
      } else {
        throw Exception('Failed to retrieve plate number');
      }
    } catch (e) {
      print('Error retrieving plate number: $e');
      rethrow; // Rethrow the exception for error handling
    }
  }
}
