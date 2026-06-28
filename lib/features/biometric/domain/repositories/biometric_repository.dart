import '../entities/biometric_timeout.dart';

abstract class BiometricRepository {
  Future<bool> isDeviceSupported();
  Future<bool> canCheckBiometrics();
  Future<List<String>> getAvailableBiometrics();
  Future<bool> authenticate({required String reason});

  Future<bool> isBiometricEnabled();
  Future<void> setBiometricEnabled(bool enabled);

  Future<BiometricTimeout> getTimeout();
  Future<void> setTimeout(BiometricTimeout timeout);

  Future<DateTime?> getLastUnlockedAt();
  Future<void> setLastUnlockedAt(DateTime? timestamp);

  Future<void> clearPreferences();
}
