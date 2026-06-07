import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

// BiometricService handles fingerprint authentication
// It uses the local_auth package which accesses the phone's biometric sensor
// This is one of the 3 mobile device capabilities demonstrated in the app
class BiometricService {
  // LocalAuthentication is the main class from the local_auth package
  final LocalAuthentication _auth = LocalAuthentication();

  // isBiometricAvailable checks if the phone supports fingerprint login
  // Returns true if the phone has a fingerprint sensor and it is set up
  // This is called when the Welcome screen loads to decide whether to show the fingerprint button
  Future<bool> isBiometricAvailable() async {
    try {
      // canCheckBiometrics checks if the phone has any biometric hardware
      final isAvailable = await _auth.canCheckBiometrics;
      // isDeviceSupported checks if the device supports biometric authentication at all
      final isSupported = await _auth.isDeviceSupported();
      // Return true if either check passes
      return isAvailable || isSupported;
    } on PlatformException catch (e) {
      // If there is any error checking biometrics, return false
      // This means the fingerprint button will not show
      return false;
    }
  }

  // authenticate shows the fingerprint scan prompt to the user
  // Returns true if the fingerprint was recognised successfully
  // Returns false if the scan failed or was cancelled
  Future<bool> authenticate() async {
    try {
      // authenticate shows the system fingerprint dialog
      final result = await _auth.authenticate(
        // This message is shown to the user on the fingerprint prompt
        localizedReason: 'Scan your fingerprint to login to MediSlot',
        options: const AuthenticationOptions(
          biometricOnly: false, // Allow PIN/pattern as fallback if fingerprint fails
          stickyAuth: true,     // Keep the prompt open if user switches apps
          useErrorDialogs: true, // Show error messages if fingerprint fails
        ),
      );
      return result; // true = success, false = failed or cancelled
    } on PlatformException catch (e) {
      // If there is any error during authentication, return false
      return false;
    }
  }
}