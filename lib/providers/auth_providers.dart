import 'package:flutter/material.dart';
import 'package:parking_system/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  final ApiService _apiService;

  AuthProvider(this._apiService);

  String? get token => _token;

  Future<void> login(String username, String password) async {
    final response = await _apiService.login(username, password);
    print(response);

    _token = response['data']['username'];
    notifyListeners();
  }

  Future<void> signup(String username, String password, String fullName,
      String email, String? phone) async {
    try {
      final response = await _apiService.signup(
        username: username,
        password: password,
        fullName: fullName,
        email: email,
        phone: phone,
      );
      // Handle response based on your application's logic
      print('Signup Response: $response');
    } catch (e) {
      // Handle errors
      print('Signup Error: $e');
    }
  }

  Future<void> logout() async {
    await _apiService.logout(_token!);
    _token = null;
    notifyListeners();
  }

  bool get isAuthenticated => _token != null;
}
