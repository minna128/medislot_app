import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../data/services/auth_service.dart';
import '../models/doctor.dart';

// Studied topics: reading data from JSON, saving data with Flutter
// Loads doctors from Laravel API when online, local JSON file when offline
class DoctorService {

  // Main method — tries Laravel API first, falls back to local JSON
  Future<List<Doctor>> getDoctors() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      try {
        return await _fetchFromApi();
      } catch (_) {
        return await _loadFromLocalJson();
      }
    } else {
      return await _loadFromLocalJson();
    }
  }

  // Fetch from Laravel API with Sanctum token
  Future<List<Doctor>> _fetchFromApi() async {
    final token = await AuthService().getToken();

    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/api/doctors'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((j) => Doctor.fromApiJson(j)).toList();
    } else {
      throw Exception('Failed to load doctors: ${response.statusCode}');
    }
  }

  // Fetch from external JSON file (fulfils scrollable list external JSON requirement)
  Future<List<Doctor>> fetchFromExternalJson() async {
    final response = await http
        .get(Uri.parse(AppConstants.externalDoctorsUrl))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((j) => Doctor.fromJson(j)).toList();
    } else {
      throw Exception('Failed to load external JSON');
    }
  }

  // Read from local JSON asset (offline fallback)
  Future<List<Doctor>> _loadFromLocalJson() async {
    final String jsonString =
        await rootBundle.loadString(AppConstants.localDoctorsJson);
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => Doctor.fromJson(j)).toList();
  }
}
