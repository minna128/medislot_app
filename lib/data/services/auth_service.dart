import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class AuthService {

  Future<void> saveLoginState({
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefIsLoggedIn, true);
    await prefs.setString(AppConstants.prefUserName, name);
    await prefs.setString(AppConstants.prefUserEmail, email);
  }

  // Just locks the screen — keeps email saved so fingerprint still works
  Future<void> lockSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefIsLoggedIn, false);
  }

  // Full sign out — clears everything including email
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check if session is active
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefIsLoggedIn) ?? false;
  }

  // Check if user has ever logged in (email is saved)
  Future<bool> hasAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(AppConstants.prefUserEmail) ?? '';
    return email.isNotEmpty;
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefUserName) ?? 'User';
  }

  Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefUserEmail) ?? '';
  }

  // Keep old logout name pointing to lockSession for compatibility
  Future<void> logout() async {
    await lockSession();
  }
}