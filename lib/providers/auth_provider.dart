import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';

// AuthProvider is part of the Provider state management pattern
// It extends ChangeNotifier which allows it to notify screens when data changes
// Instead of each screen loading user data separately, AuthProvider loads it ONCE
// and shares it with every screen that is listening
// For example: ProfileScreen and HomeScreen both need the user's name
// Without Provider they would each call SharedPreferences separately
// With Provider they both just read from AuthProvider — much more efficient
class AuthProvider extends ChangeNotifier {
  // AuthService handles all the actual API calls and SharedPreferences operations
  final AuthService _authService = AuthService();

  // These are private variables — they store the current user's data
  // Private means they can only be changed from inside this class
  String _userName  = '';
  String _userEmail = '';
  String _userRole  = '';
  bool _isLoggedIn  = false;
  bool _isLoading   = false;

  // Getters allow screens to READ these values but not change them directly
  // Screens use context.watch<AuthProvider>().userName to get the value
  String get userName  => _userName;
  String get userEmail => _userEmail;
  String get userRole  => _userRole;
  bool get isLoggedIn  => _isLoggedIn;
  bool get isLoading   => _isLoading;

  // loadUser is called once when the app starts (in main.dart AppStartup)
  // It reads the saved user data from SharedPreferences and stores it here
  // This way all screens can access user data without reading SharedPreferences themselves
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners(); // Tell all listening screens to show a loading indicator

    // Read user data from SharedPreferences via AuthService
    _isLoggedIn  = await _authService.isLoggedIn();
    _userName    = await _authService.getUserName();
    _userEmail   = await _authService.getUserEmail();
    _userRole    = await _authService.getUserRole();

    _isLoading = false;
    notifyListeners(); // Tell all listening screens that data is ready — rebuild!
  }

  // login calls the Laravel API via AuthService
  // If successful, it updates all the user data stored in this provider
  // notifyListeners() then tells ALL screens watching this provider to rebuild
  // This is why ProfileScreen automatically shows the correct name after login
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Call the Laravel /api/login endpoint via AuthService
    final result = await _authService.login(email, password);

    if (result['success']) {
      // Login worked — update all user data in the provider
      _isLoggedIn  = true;
      _userName    = await _authService.getUserName();
      _userEmail   = await _authService.getUserEmail();
      _userRole    = await _authService.getUserRole();
    }

    _isLoading = false;
    notifyListeners(); // Rebuild all screens watching this provider
    return result;     // Return result to LoginScreen so it can navigate or show error
  }

  // register calls the Laravel API to create a new patient account
  // Same pattern as login — update state and notify listeners on success
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Call the Laravel /api/register endpoint via AuthService
    final result = await _authService.register(name, email, password);

    if (result['success']) {
      // Registration worked — update all user data in the provider
      _isLoggedIn  = true;
      _userName    = await _authService.getUserName();
      _userEmail   = await _authService.getUserEmail();
      _userRole    = await _authService.getUserRole();
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // logout clears all user data from the provider
  // notifyListeners() tells all screens watching this provider to rebuild
  // This is why ProfileScreen immediately shows empty data after logout
  Future<void> logout() async {
    // Call AuthService to revoke token on server and clear SharedPreferences
    await _authService.logout();

    // Clear all user data stored in this provider
    _isLoggedIn  = false;
    _userName    = '';
    _userEmail   = '';
    _userRole    = '';

    notifyListeners(); // All screens watching this provider will rebuild
  }
}