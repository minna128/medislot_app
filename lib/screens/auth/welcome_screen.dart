import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/biometric_service.dart';
import '../main_tabs.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

// WelcomeScreen is the FIRST screen the user sees when they open the app
// It has 3 ways to access the app: Email Login, Create Account, Fingerprint
// The design matches the Laravel website - same colors, logo, background image
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // AuthService handles all API calls - login, logout, getting saved user data
  final _authService = AuthService();

  // BiometricService handles fingerprint sensor using the local_auth package
  final _biometricService = BiometricService();

  // This variable controls whether the fingerprint button shows or not
  // If the phone does not support fingerprint, this stays false and button is hidden
  bool _biometricAvailable = false;

  // initState runs ONCE when the screen is first created
  // We use it to check if fingerprint is available on this device
  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  // This method asks the local_auth package if the phone has a fingerprint sensor
  // If yes, _biometricAvailable becomes true and the fingerprint button appears
  Future<void> _checkBiometrics() async {
    final available = await _biometricService.isBiometricAvailable();
    if (!mounted) return; // Safety check - don't update if screen is closed
    setState(() => _biometricAvailable = available);
  }

  // This method handles the fingerprint login process
  // It only works if the user has logged in with email at least once before
  // Because we need a saved Sanctum token to restore their session
  Future<void> _biometricLogin() async {

    // Step 1: Check if a Sanctum token is saved from a previous email login
    // The token is stored in SharedPreferences after email login
    final token = await _authService.getToken();

    // If no token found, show a message asking user to login with email first
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please login with email first before using fingerprint'),
              backgroundColor: Colors.orange));
      return;
    }

    // Step 2: Ask the user to scan their fingerprint
    // This uses the local_auth package which is a mobile device sensor capability
    final authenticated = await _biometricService.authenticate();
    if (!mounted) return;

    if (authenticated) {
      // Step 3: Fingerprint matched successfully
      // Mark the user as logged in in SharedPreferences
      // Then navigate to the main app (MainTabs)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const MainTabs()));
    } else {
      // Fingerprint scan failed - show error message
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Fingerprint not recognised. Try again.'),
              backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        // Stack allows us to place widgets on top of each other
        // Layer 1 (bottom): background image
        // Layer 2 (middle): dark overlay
        // Layer 3 (top): all the text and buttons
        fit: StackFit.expand,
        children: [

          // LAYER 1: Background image loaded from the internet
          // This is the same medical equipment photo used on the Laravel website
          // errorBuilder shows a dark background if the image fails to load
          Image.network(
            'https://images.unsplash.com/photo-1504439468489-c8920d796a29?w=1200&q=80',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: const Color(0xFF050A1E)),
          ),

          // LAYER 2: Dark gradient overlay on top of the background image
          // Without this, the white text would be hard to read over the bright image
          // The gradient goes from dark at top to very dark at bottom
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xE6050A1E), // Dark navy at top
                  Color(0xCC050A1E), // Slightly lighter in middle
                  Color(0xF5050A1E), // Very dark at bottom
                ],
              ),
            ),
          ),

          // LAYER 3: Main content - logo, text, and buttons
          // SafeArea makes sure content doesn't overlap with phone's status bar
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),

                  // App logo - SVG file extracted from the Laravel project's public folder
                  // flutter_svg package is used to render SVG files in Flutter
                  SvgPicture.asset('assets/images/logo.svg', width: 72, height: 72),

                  const SizedBox(height: 20),

                  // App name using RichText so we can have two different colors
                  // "Medi" in white and "Slot" in teal - matches the Laravel website
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 32,
                          fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(text: 'Medi',
                            style: TextStyle(color: Colors.white)),
                        TextSpan(text: 'Slot',
                            style: TextStyle(color: Color(0xFF2DD4BF))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Trust badge - shows "Trusted by 1,000+ Patients"
                  // Matches the badge shown on the Laravel welcome page
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0x262DD4BF),
                      border: Border.all(color: const Color(0x4D2DD4BF)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Small green circle dot on the left
                        Container(
                          width: 7, height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2DD4BF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Trusted by 1,000+ Patients',
                            style: TextStyle(
                                fontFamily: 'Poppins', fontSize: 13,
                                color: Color(0xFF2DD4BF),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Main headline - matches the Laravel website text
                  // "Better Doctors." in white
                  const Text('Better Doctors.',
                      style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 28,
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  // "Better Care." in teal - accent color
                  const Text('Better Care.',
                      style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2DD4BF))),

                  const SizedBox(height: 16),

                  // Subtitle text explaining the app
                  const Text(
                    'Book appointments with certified specialists online — fast, easy, and secure.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Poppins', fontSize: 14,
                        color: Colors.white70, height: 1.6),
                  ),

                  const SizedBox(height: 48),

                  // LOGIN BUTTON - teal background
                  // Navigates to LoginScreen when tapped
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => LoginScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(
                            fontFamily: 'Poppins', fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Login'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // CREATE ACCOUNT BUTTON - outlined style
                  // Navigates to RegisterScreen when tapped
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => RegisterScreen())),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(
                            fontFamily: 'Poppins', fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Create Account'),
                    ),
                  ),

                  // FINGERPRINT SECTION
                  // Only shows if _biometricAvailable is true
                  // This means the phone supports fingerprint login
                  if (_biometricAvailable) ...[
                    const SizedBox(height: 32),

                    // "or" divider line
                    Row(children: [
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or', style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 13,
                            color: Colors.white54)),
                      ),
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                    ]),
                    const SizedBox(height: 24),

                    // Fingerprint button - calls _biometricLogin when tapped
                    // Uses the fingerprint sensor (mobile device capability)
                    GestureDetector(
                      onTap: _biometricLogin,
                      child: Column(children: [
                        // Circular container with fingerprint icon
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0x262DD4BF),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0x4D2DD4BF), width: 1.5),
                          ),
                          child: const Icon(Icons.fingerprint,
                              size: 36, color: Color(0xFF2DD4BF)),
                        ),
                        const SizedBox(height: 8),
                        const Text('Login with Fingerprint',
                            style: TextStyle(fontFamily: 'Poppins',
                                fontSize: 13, fontWeight: FontWeight.w500,
                                color: Color(0xFF2DD4BF))),
                      ]),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}