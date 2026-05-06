import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      print('Biometric available: $isAvailable, supported: $isSupported');
      return isAvailable || isSupported;
    } on PlatformException catch (e) {
      print('Biometric check error: $e');
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final List<BiometricType> availableBiometrics =
      await _auth.getAvailableBiometrics();
      print('Available biometrics: $availableBiometrics');

      final result = await _auth.authenticate(
        localizedReason: 'Scan your fingerprint to login to MediSlot',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      print('Auth result: $result');
      return result;
    } on PlatformException catch (e) {
      print('Auth error code: ${e.code}');
      print('Auth error message: ${e.message}');
      return false;
    }
  }
}