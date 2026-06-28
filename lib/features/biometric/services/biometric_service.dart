import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuth;

  BiometricService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  Future<bool> isDeviceSupported() async {
    return await _localAuth.isDeviceSupported();
  }

  Future<bool> canCheckBiometrics() async {
    return await _localAuth.canCheckBiometrics;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  Future<bool> authenticate({required String reason}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // allows PIN/pattern/password fallback natively
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<String> getCapabilityStatus() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) {
        return 'No biometric hardware';
      }

      final canCheck = await _localAuth.canCheckBiometrics;
      final available = await _localAuth.getAvailableBiometrics();

      if (available.isEmpty) {
        if (canCheck) {
          return 'No biometric credentials enrolled';
        } else {
          return 'Device credentials only';
        }
      }

      final hasFace = available.contains(BiometricType.face);
      final hasFingerprint = available.contains(BiometricType.fingerprint);
      final hasStrong = available.contains(BiometricType.strong);

      if (hasFace) {
        return 'Face ID available';
      } else if (hasFingerprint) {
        return 'Fingerprint available';
      } else if (hasStrong) {
        return 'Strong biometrics available';
      } else {
        return 'Device credentials only';
      }
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
        return 'Hardware temporarily unavailable';
      }
      return 'Unavailable';
    } catch (_) {
      return 'Unavailable';
    }
  }
}
