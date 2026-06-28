import '../../domain/entities/biometric_timeout.dart';
import '../../domain/repositories/biometric_repository.dart';
import '../../services/biometric_service.dart';
import '../../services/secure_storage_service.dart';

class BiometricRepositoryImpl implements BiometricRepository {
  final BiometricService _biometricService;
  final SecureStorageService _secureStorageService;

  static const _keyEnabled = 'biometric_enabled';
  static const _keyTimeout = 'biometric_timeout';
  static const _keyLastUnlocked = 'biometric_last_unlocked';

  BiometricRepositoryImpl({
    required BiometricService biometricService,
    required SecureStorageService secureStorageService,
  })  : _biometricService = biometricService,
        _secureStorageService = secureStorageService;

  @override
  Future<bool> isDeviceSupported() => _biometricService.isDeviceSupported();

  @override
  Future<bool> canCheckBiometrics() => _biometricService.canCheckBiometrics();

  @override
  Future<List<String>> getAvailableBiometrics() async {
    final list = await _biometricService.getAvailableBiometrics();
    return list.map((e) => e.name).toList();
  }

  @override
  Future<bool> authenticate({required String reason}) =>
      _biometricService.authenticate(reason: reason);

  @override
  Future<bool> isBiometricEnabled() async {
    final val = await _secureStorageService.read(_keyEnabled);
    return val == 'true';
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorageService.write(_keyEnabled, enabled.toString());
  }

  @override
  Future<BiometricTimeout> getTimeout() async {
    final val = await _secureStorageService.read(_keyTimeout);
    return BiometricTimeout.fromString(val);
  }

  @override
  Future<void> setTimeout(BiometricTimeout timeout) async {
    await _secureStorageService.write(_keyTimeout, timeout.name);
  }

  @override
  Future<DateTime?> getLastUnlockedAt() async {
    final val = await _secureStorageService.read(_keyLastUnlocked);
    if (val == null) return null;
    return DateTime.tryParse(val);
  }

  @override
  Future<void> setLastUnlockedAt(DateTime? timestamp) async {
    if (timestamp == null) {
      await _secureStorageService.delete(_keyLastUnlocked);
    } else {
      await _secureStorageService.write(_keyLastUnlocked, timestamp.toIso8601String());
    }
  }

  @override
  Future<void> clearPreferences() async {
    await _secureStorageService.delete(_keyEnabled);
    await _secureStorageService.delete(_keyTimeout);
    await _secureStorageService.delete(_keyLastUnlocked);
  }
}
