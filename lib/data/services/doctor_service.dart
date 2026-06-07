import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../data/services/auth_service.dart';
import '../models/doctor.dart';

// DoctorService is responsible for loading doctor data into the app
// It has 3 data sources and automatically picks the right one:
// 1. Laravel API — when online (live data from AWS server)
// 2. External JSON — fetched from GitHub when user taps the toggle button
// 3. Local JSON — read from the app itself when there is no internet
// This satisfies the data requirements: API, external JSON, and local JSON fallback
class DoctorService {

  // getDoctors is the main method called by the app to load doctors
  // It first checks if the device is online using connectivity_plus
  // If online — tries the Laravel API, falls back to local JSON if API fails
  // If offline — goes straight to local JSON
  Future<List<Doctor>> getDoctors() async {
    // Check internet connection using connectivity_plus package
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult.any((r) =>
    r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);

    if (isOnline) {
      try {
        // Try to fetch from the Laravel API first
        return await _fetchFromApi();
      } catch (_) {
        // If API fails for any reason, fall back to local JSON
        return await _loadFromLocalJson();
      }
    } else {
      // No internet — load from local JSON file stored in the app
      return await _loadFromLocalJson();
    }
  }

  // _fetchFromApi fetches doctors from the Laravel backend on AWS
  // It sends the Sanctum token in the Authorization header
  // so the API knows the user is authenticated
  Future<List<Doctor>> _fetchFromApi() async {
    // Get the saved Sanctum token from SharedPreferences
    final token = await AuthService().getToken();

    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/api/doctors'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Sanctum token for authentication
      },
    ).timeout(const Duration(seconds: 10)); // Timeout after 10 seconds

    if (response.statusCode == 200) {
      // Decode the JSON response and convert each item to a Doctor object
      // Using fromApiJson because the API uses different field names
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((j) => Doctor.fromApiJson(j)).toList();
    } else {
      throw Exception('Failed to load doctors: ${response.statusCode}');
    }
  }

  // fetchFromExternalJson fetches doctors from the GitHub-hosted JSON file
  // This is called when the user taps the toggle button in the Doctors screen
  // It satisfies the requirement: "connect to internet to get data from external JSON file"
  // The URL points to: assets/doctors.json in the GitHub repository
  Future<List<Doctor>> fetchFromExternalJson() async {
    final response = await http
        .get(Uri.parse(AppConstants.externalDoctorsUrl))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      // Using fromJson because external JSON uses same field names as local JSON
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((j) => Doctor.fromJson(j)).toList();
    } else {
      throw Exception('Failed to load external JSON');
    }
  }

  // _loadFromLocalJson reads doctors from the local JSON file bundled with the app
  // This is used when there is no internet connection
  // It satisfies the requirement: "provide suitable content from local JSON if offline"
  // rootBundle is Flutter's way of reading files from the assets folder
  Future<List<Doctor>> _loadFromLocalJson() async {
    final String jsonString =
    await rootBundle.loadString(AppConstants.localDoctorsJson);
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => Doctor.fromJson(j)).toList();
  }
}