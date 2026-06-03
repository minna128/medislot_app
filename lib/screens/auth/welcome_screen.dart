import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/biometric_service.dart';
import '../main_tabs.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _authService = AuthService();
  final _biometricService = BiometricService();
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await _biometricService.isBiometricAvailable();
    if (!mounted) return;
    setState(() => _biometricAvailable = available);
  }

  Future<void> _biometricLogin() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please login with email first before using fingerprint'),
              backgroundColor: Colors.orange));
      return;
    }

    final authenticated = await _biometricService.authenticate();
    if (!mounted) return;

    if (authenticated) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const MainTabs()));
    } else {
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
        fit: StackFit.expand,
        children: [
          // Hero background image (same as Laravel website)
          Image.network(
            'https://images.unsplash.com/photo-1504439468489-c8920d796a29?w=1200&q=80',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: const Color(0xFF050A1E)),
          ),

          // Dark overlay (same gradient as Laravel)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xE6050A1E),
                  Color(0xCC050A1E),
                  Color(0xF5050A1E),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),

                  // Logo � teal box with heartbeat icon (matches website)
                  SvgPicture.asset('assets/images/logo.svg', width: 72, height: 72),

                  const SizedBox(height: 20),

                  // Brand name
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

                  // Trusted badge (matches website)
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

                  // Headline
                  const Text('Better Doctors.',
                      style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 28,
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('Better Care.',
                      style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2DD4BF))),

                  const SizedBox(height: 16),

                  const Text(
                    'Book appointments with certified specialists online � fast, easy, and secure.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Poppins', fontSize: 14,
                        color: Colors.white70, height: 1.6),
                  ),

                  const SizedBox(height: 48),

                  // Login button (teal � matches "Book Now")
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

                  // Register button (outlined � matches "Log In" outline)
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

                  if (_biometricAvailable) ...[
                    const SizedBox(height: 32),
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
                    GestureDetector(
                      onTap: _biometricLogin,
                      child: Column(children: [
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
