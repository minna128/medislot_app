import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class AuthService {

  // ── API Login ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await _saveSession(
        token: data['token'],
        name:  data['user']['name'],
        email: data['user']['email'],
        role:  data['user']['role'],
      );
      return {'success': true};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Login failed'};
    }
  }

  // ── API Register ───────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'name':                  name,
        'email':                 email,
        'password':              password,
        'password_confirmation': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
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

  // ── API Logout ─────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/logout'),
        headers: {
          'Content-Type':  'application/json',
          'Accept':        'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    }
    await signOut();
  }

  // ── Session Helpers ────────────────────────────────────────────────────────
  Future<void> _saveSession({
    required String token,
    required String name,
    required String email,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefIsLoggedIn, true);
    await prefs.setString(AppConstants.prefApiToken,   token);
    await prefs.setString(AppConstants.prefUserName,   name);
    await prefs.setString(AppConstants.prefUserEmail,  email);
    await prefs.setString(AppConstants.prefUserRole,   role);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    // Keep token for biometric login but mark as logged out
    final token = prefs.getString(AppConstants.prefApiToken);
    final name = prefs.getString(AppConstants.prefUserName);
    final email = prefs.getString(AppConstants.prefUserEmail);
    final role = prefs.getString(AppConstants.prefUserRole);
    await prefs.clear();
    // Restore token and user info for biometric
    if (token != null) await prefs.setString(AppConstants.prefApiToken, token);
    if (name != null) await prefs.setString(AppConstants.prefUserName, name);
    if (email != null) await prefs.setString(AppConstants.prefUserEmail, email);
    if (role != null) await prefs.setString(AppConstants.prefUserRole, role);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefIsLoggedIn) ?? false;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefApiToken);
  }

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