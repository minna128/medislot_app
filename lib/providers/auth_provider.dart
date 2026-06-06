import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Studied topic: State Management with Provider
// AuthProvider manages authentication state across the entire app
// Any screen can listen to this provider and rebuild when auth state changes
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String _userName = '';
  String _userEmail = '';
  String _userRole = '';
  bool _isLoggedIn = false;
  bool _isLoading = false;

  // Getters — screens read these values
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userRole => _userRole;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  // Load user data from SharedPreferences on app start
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    _isLoggedIn  = await _authService.isLoggedIn();
    _userName    = await _authService.getUserName();
    _userEmail   = await _authService.getUserEmail();
    _userRole    = await _authService.getUserRole();

    _isLoading = false;
    notifyListeners();
  }

  // Login — calls API and updates state
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(email, password);

    if (result['success']) {
      _isLoggedIn  = true;
      _userName    = await _authService.getUserName();
      _userEmail   = await _authService.getUserEmail();
      _userRole    = await _authService.getUserRole();
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // Register — calls API and updates state
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.register(name, email, password);

    if (result['success']) {
      _isLoggedIn  = true;
      _userName    = await _authService.getUserName();
      _userEmail   = await _authService.getUserEmail();
      _userRole    = await _authService.getUserRole();
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // Logout — clears state
  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn  = false;
    _userName    = '';
    _userEmail   = '';
    _userRole    = '';
    notifyListeners();
  }
}