import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../main_tabs.dart';
import 'register_screen.dart';

// LoginScreen is where the user enters their email and password to log in
// It uses AuthProvider (state management) to handle the login process
// This satisfies the requirement: "initial screen with a well-designed mobile form for login"
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // _formKey is used to validate the form fields before submitting
  final _formKey = GlobalKey<FormState>();

  // Controllers hold the text the user types in each field
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading       = false; // True while waiting for API response
  bool _obscurePassword = true;  // Controls whether password is hidden or visible
  String? _errorMessage;         // Stores error message from API if login fails

  @override
  void dispose() {
    // Always dispose controllers when screen is closed to free memory
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // _login is called when the user taps the Login button
  // It validates the form, then calls AuthProvider to log in via the Laravel API
  Future<void> _login() async {
    // Stop if form validation fails — e.g. empty email or short password
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear any previous error message
    });

    // Call AuthProvider.login() — this is Provider state management in action
    // context.read<AuthProvider>() gets the AuthProvider instance
    // After login, AuthProvider updates the user data for ALL screens automatically
    final result = await context.read<AuthProvider>().login(
      _emailController.text.trim(), // trim() removes any accidental spaces
      _passwordController.text,
    );

    if (!mounted) return; // Safety check — don't update if screen is closed

    if (result['success']) {
      // Login successful — navigate to MainTabs and remove all previous screens
      // pushAndRemoveUntil means the user cannot go back to the login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainTabs()),
            (route) => false,
      );
    } else {
      // Login failed — show the error message from the API
      setState(() {
        _isLoading = false;
        _errorMessage = result['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          // Form widget groups all the form fields together
          // The _formKey allows us to validate all fields at once
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page title and subtitle
                Text('Welcome back',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Login to your account',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 40),

                // EMAIL FIELD — validates that it is not empty and contains @
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress, // Shows email keyboard
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null; // null means validation passed
                  },
                ),
                const SizedBox(height: 16),

                // PASSWORD FIELD — hidden by default, eye icon toggles visibility
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword, // Hides password when true
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    // Eye icon to show/hide password
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),

                // ERROR MESSAGE — shows in red if login fails
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorMessage!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 14)),
                ],
                const SizedBox(height: 32),

                // LOGIN BUTTON — shows loading spinner while waiting for API
                ElevatedButton(
                  onPressed: _isLoading ? null : _login, // Disabled while loading
                  child: _isLoading
                      ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                      : const Text('Login'),
                ),
                const SizedBox(height: 16),

                // REGISTER LINK — navigates to RegisterScreen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?",
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7))),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => RegisterScreen())),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}