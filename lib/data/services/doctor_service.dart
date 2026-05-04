import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/constants/app_constants.dart';
import '../models/doctor.dart';

// Studied topics: reading data from JSON, saving data with Flutter
// Loads doctors from external URL when online, local JSON file when offline
class DoctorService {

  // Main method — tries online first, falls back to local JSON
  Future<List<Doctor>> getDoctors() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      try {
        return await _fetchFromNetwork();
      } catch (_) {
        // Network failed — fall back to local file
        return await _loadFromLocalJson();
      }
    } else {
      // Offline — read from local asset file
      return await _loadFromLocalJson();
    }
  }

  // Fetch from external URL (fulfils "connect to internet" requirement)
  Future<List<Doctor>> _fetchFromNetwork() async {
    final response = await http
        .get(Uri.parse(AppConstants.externalDoctorsUrl))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((j) => Doctor.fromJson(j)).toList();
    } else {
      throw Exception('Failed to load doctors: ${response.statusCode}');
    }
  }

  // Read from local JSON asset (fulfils "read from local JSON when offline" requirement)
  // Studied topic: reading data from JSON
  Future<List<Doctor>> _loadFromLocalJson() async {
    final String jsonString =
        await rootBundle.loadString(AppConstants.localDoctorsJson);
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => Doctor.fromJson(j)).toList();
  }
}
