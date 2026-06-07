import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../main_tabs.dart';
import 'login_screen.dart';

// RegisterScreen allows new users to create a MediSlot account
// It sends the registration data to the Laravel API via AuthService
// This satisfies the requirement: "link to a register screen"
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // _formKey is used to validate all form fields at once when Register is tapped
  final _formKey = GlobalKey<FormState>();

  // Controllers hold the text typed in each form field
  final _nameController            = TextEditingController();
  final _emailController           = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // AuthService handles the actual API registration call
  final _authService = AuthService();

  bool _isLoading       = false; // True while waiting for API response
  bool _obscurePassword = true;  // Controls password field visibility
  bool _obscureConfirm  = true;  // Controls confirm password field visibility
  bool _termsAccepted   = false; // Tracks whether user accepted terms
  String _selectedGender = '';   // Stores selected gender from dropdown

  // Gender options for the dropdown
  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    // Always dispose all controllers when screen is closed to free memory
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // _register is called when the user taps the Register button
  // It validates the form, checks terms acceptance, then calls the Laravel API
  Future<void> _register() async {
    // Stop if any form field fails validation
    if (!_formKey.currentState!.validate()) return;

    // Check if user accepted the terms and conditions
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept the Terms & Conditions')));
      return;
    }

    setState(() => _isLoading = true);

    // Call AuthService to send registration data to the Laravel /api/register endpoint
    final result = await _authService.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return; // Safety check — don't update if screen is closed

    if (result['success']) {
      // Registration successful — navigate to MainTabs
      // pushAndRemoveUntil removes all previous screens so user cannot go back
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainTabs()),
            (route) => false,
      );
    } else {
      // Registration failed — show error message from API
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Registration failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          // Form widget groups all fields — _formKey validates them all at once
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page title
                Text('Create your account',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),

                // FULL NAME FIELD — required, auto-capitalises words
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                ),
                const SizedBox(height: 16),

                // EMAIL FIELD — validates format with @ check
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // PASSWORD FIELD — minimum 8 characters, eye icon to toggle visibility
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
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
                    if (v.length < 8) return 'Minimum 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // CONFIRM PASSWORD FIELD — must match the password field above
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  // Validator checks if this field matches the password field
                  validator: (v) =>
                  v != _passwordController.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 16),

                // GENDER DROPDOWN — optional selection from Male, Female, Other
                DropdownButtonFormField<String>(
                  value: _selectedGender.isEmpty ? null : _selectedGender,
                  decoration: const InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.wc_outlined)),
                  items: _genders
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedGender = v ?? ''),
                ),
                const SizedBox(height: 20),

                // TERMS AND CONDITIONS CHECKBOX — must be ticked to register
                Row(
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      onChanged: (v) =>
                          setState(() => _termsAccepted = v ?? false),
                    ),
                    const Expanded(
                        child: Text('I agree to the Terms & Conditions')),
                  ],
                ),
                const SizedBox(height: 24),

                // REGISTER BUTTON — shows loading spinner while API call is in progress
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                      : const Text('Register'),
                ),
                const SizedBox(height: 16),

                // LOGIN LINK — goes back to LoginScreen if user already has an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7))),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => LoginScreen())),
                      child: const Text('Login'),
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