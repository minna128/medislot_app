import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

// Studied topic: saving data with Flutter (SharedPreferences)
// Simple local auth — saves login state on the device.
// No Firebase yet (not studied). Firebase can be added later.
class AuthService {
  // Save login state after user registers or logs in
  Future<void> saveLoginState({
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefIsLoggedIn, true);
    await prefs.setString(AppConstants.prefUserName, name);
    await prefs.setString(AppConstants.prefUserEmail, email);
  }

  // Check if user is already logged in (app restart)
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefIsLoggedIn) ?? false;
  }

  // Get saved user name
  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefUserName) ?? 'User';
  }

  // Get saved user email
  Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefUserEmail) ?? '';
  }

  // Clear all saved data on logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
