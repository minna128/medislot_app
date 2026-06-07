import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

// AuthService handles all authentication-related API calls
// It communicates with the Laravel backend using Sanctum token authentication
// It also saves and retrieves user session data using SharedPreferences
class AuthService {

  // LOGIN — sends email and password to the Laravel API
  // Returns success:true if login worked, or success:false with an error message
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Send a POST request to the Laravel /api/login endpoint
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    // Decode the JSON response from the API
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Login successful — save the token and user details to SharedPreferences
      await _saveSession(
        token: data['token'],       // Sanctum token used for future API requests
        name:  data['user']['name'],
        email: data['user']['email'],
        role:  data['user']['role'], // Role is either "admin", "doctor" or "patient"
      );
      return {'success': true};
    } else {
      // Login failed — return the error message from the API
      return {'success': false, 'message': data['message'] ?? 'Login failed'};
    }
  }

  // REGISTER — creates a new patient account via the Laravel API
  // Returns success:true if registration worked, or success:false with an error message
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    // Send a POST request to the Laravel /api/register endpoint
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'name':                  name,
        'email':                 email,
        'password':              password,
        'password_confirmation': password, // Laravel requires password confirmation
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      // Registration successful — save session just like login
      await _saveSession(
        token: data['token'],
        name:  data['user']['name'],
        email: data['user']['email'],
        role:  data['user']['role'],
      );
      return {'success': true};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Registration failed'};
    }
  }

  // LOGOUT — revokes the Sanctum token on the Laravel server
  // Then clears the local session while keeping token for biometric login
  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      // Send logout request to Laravel API to invalidate the token on the server
      await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/logout'),
        headers: {
          'Content-Type':  'application/json',
          'Accept':        'application/json',
          'Authorization': 'Bearer $token', // Send token in header to identify user
        },
      );
    }
    // Clear local session data
    await signOut();
  }

  // _saveSession saves all user data to SharedPreferences after login or register
  // SharedPreferences keeps this data even after the app is closed
  Future<void> _saveSession({
    required String token,
    required String name,
    required String email,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefIsLoggedIn, true);  // Mark user as logged in
    await prefs.setString(AppConstants.prefApiToken,   token); // Save Sanctum token
    await prefs.setString(AppConstants.prefUserName,   name);
    await prefs.setString(AppConstants.prefUserEmail,  email);
    await prefs.setString(AppConstants.prefUserRole,   role);
  }

  // signOut clears the session but KEEPS the token and user info
  // This is important for fingerprint login — after logout the user can still
  // use fingerprint to log back in because the token is still saved
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();

    // Save token and user info before clearing
    final token = prefs.getString(AppConstants.prefApiToken);
    final name  = prefs.getString(AppConstants.prefUserName);
    final email = prefs.getString(AppConstants.prefUserEmail);
    final role  = prefs.getString(AppConstants.prefUserRole);

    // Clear everything from SharedPreferences
    await prefs.clear();

    // Restore token and user info so fingerprint login still works
    if (token != null) await prefs.setString(AppConstants.prefApiToken, token);
    if (name  != null) await prefs.setString(AppConstants.prefUserName,  name);
    if (email != null) await prefs.setString(AppConstants.prefUserEmail, email);
    if (role  != null) await prefs.setString(AppConstants.prefUserRole,  role);
  }

  // isLoggedIn checks if the user is currently logged in
  // Returns true or false based on what is saved in SharedPreferences
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefIsLoggedIn) ?? false;
  }

  // getToken returns the saved Sanctum token
  // This token is sent in the Authorization header for all protected API requests
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefApiToken);
  }

  // The following methods return saved user details from SharedPreferences
  // These are used to display user info on the Profile screen
  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefUserName) ?? 'User';
  }

  Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefUserEmail) ?? '';
  }

  Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefUserRole) ?? 'patient';
  }
}