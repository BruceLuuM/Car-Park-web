import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signin'),
        body: jsonEncode({'username': username, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Handle non-200 status codes
        print('Failed to login. Status code: ${response.statusCode}');
        return {'error': 'Failed to login'};
      }
    } catch (e) {
      // Handle any exceptions
      print('Error: $e');
      return {'error': 'An error occurred during login'};
    }
  }

  Future<Map<String, dynamic>> signup({
    required String username,
    required String password,
    required String fullName,
    required String email,
    String? phone,
  }) async {
    print(username);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        body: jsonEncode({
          'username': username,
          'password': password,
          'full_name': fullName,
          'email': email,
          'phone': phone ?? '',
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Handle non-200 status codes
        print('Failed to signup. Status code: ${response.statusCode}');
        return {'error': 'Failed to signup'};
      }
    } catch (e) {
      // Handle any exceptions
      print('Error: $e');
      return {'error': 'An error occurred during login'};
    }
  }

  Future<void> logout(String token) async {
    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Map<String, dynamic>> createCard(Map<String, dynamic> cardData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/parking/card'),
      body: jsonEncode(cardData),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateCard(
      int id, Map<String, dynamic> cardData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/parking/card/$id'),
      body: jsonEncode(cardData),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createParking(
      Map<String, dynamic> parkingData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/parking/create'),
      body: jsonEncode(parkingData),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> completeParking(
      int id, Map<String, dynamic> parkingData) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/parking/complete'),
      body: jsonEncode(parkingData),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  Future<List<Map<String, dynamic>>> getParkings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/parking'),
      headers: {'Content-Type': 'application/json'},
    );
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }

  Future<Map<String, dynamic>> getParking(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/parking/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
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
