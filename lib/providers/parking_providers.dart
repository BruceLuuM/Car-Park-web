import 'package:flutter/material.dart';
import 'package:parking_system/services/api_service.dart';
import 'package:parking_system/services/mock_api_service.dart';

class ParkingProvider with ChangeNotifier {
  final ApiService _apiService;

  List<Map<String, dynamic>> _parkings = [];

  ParkingProvider(this._apiService);

  List<Map<String, dynamic>> get parkings => _parkings;

  Future<void> fetchParkings() async {
    print('Fetching parkings...');

    _parkings = await _apiService.getParkings();
    print('Fetched parkings: $_parkings');

    // notifyListeners();
  }

  Future<void> createParking(Map<String, dynamic> parkingData) async {
    await _apiService.createParking(parkingData);
    fetchParkings();
  }

  Future<void> completeParking(int id, Map<String, dynamic> parkingData) async {
    await _apiService.completeParking(id, parkingData);
    fetchParkings();
  }

  openServo() {
    _apiService.openServo();
    fetchParkings();
  }
}
