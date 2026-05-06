import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/biometric_service.dart';
import '../main_tabs.dart';
import 'login_screen.dart';
import 'register_screen.dart';

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
    _debugCheckLogin();
  }

  Future<void> _checkBiometrics() async {
    final available = await _biometricService.isBiometricAvailable();
    if (!mounted) return;
    setState(() => _biometricAvailable = available);
  }

  Future<void> _debugCheckLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final email = prefs.getString('user_email') ?? 'none';
    final name = prefs.getString('user_name') ?? 'none';
    print('=== DEBUG ===');
    print('isLoggedIn: $isLoggedIn');
    print('email: $email');
    print('name: $name');
  }

  Future<void> _biometricLogin() async {
    // Check if user has ever logged in before (email is saved)
    final hasAccount = await _authService.hasAccount();
    if (!hasAccount) {
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
      // Re-activate the session
      final name = await _authService.getUserName();
      final email = await _authService.getUserEmail();
      await _authService.saveLoginState(name: name, email: email);

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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: Icon(Icons.local_hospital_rounded,
                      size: 56, color: cs.primary)),

              const SizedBox(height: 24),

              Text('MediSlot',
                  style: TextStyle(fontFamily: 'Poppins',
                      fontSize: 28, fontWeight: FontWeight.bold,
                      color: cs.onBackground)),

              const SizedBox(height: 8),

              Text('Book clinic appointments easily\nfrom your phone.',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                      color: cs.onBackground.withOpacity(0.5), height: 1.5),
                  textAlign: TextAlign.center),

              const SizedBox(height: 56),

              ElevatedButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Login with Email')),

              const SizedBox(height: 12),

              OutlinedButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text('Create Account')),

              if (_biometricAvailable) ...[
                const SizedBox(height: 24),

                Row(children: [
                  Expanded(child: Divider(
                      color: cs.onBackground.withOpacity(0.15))),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                              color: cs.onBackground.withOpacity(0.4)))),
                  Expanded(child: Divider(
                      color: cs.onBackground.withOpacity(0.15))),
                ]),

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: _biometricLogin,
                  child: Column(children: [
                    Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: cs.primary.withOpacity(0.3), width: 1.5)),
                        child: Icon(Icons.fingerprint,
                            size: 36, color: cs.primary)),
                    const SizedBox(height: 8),
                    Text('Login with Fingerprint',
                        style: TextStyle(fontFamily: 'Poppins',
                            fontSize: 13, fontWeight: FontWeight.w500,
                            color: cs.primary)),
                  ]),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}