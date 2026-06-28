import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../dependency_injection/injection.dart';
import '../../domain/entities/biometric_timeout.dart';
import '../../domain/repositories/biometric_repository.dart';
import '../../services/biometric_service.dart';

class BiometricState extends Equatable {
  final bool isEnabled;
  final BiometricTimeout timeout;
  final bool isLocked;
  final String supportedMethod;
  final bool isHardwareSupported;
  final bool isAuthenticating;
  final DateTime? lastUnlockedAt;

  const BiometricState({
    required this.isEnabled,
    required this.timeout,
    required this.isLocked,
    required this.supportedMethod,
    required this.isHardwareSupported,
    this.isAuthenticating = false,
    this.lastUnlockedAt,
  });

  BiometricState copyWith({
    bool? isEnabled,
    BiometricTimeout? timeout,
    bool? isLocked,
    String? supportedMethod,
    bool? isHardwareSupported,
    bool? isAuthenticating,
    DateTime? lastUnlockedAt,
  }) {
    return BiometricState(
      isEnabled: isEnabled ?? this.isEnabled,
      timeout: timeout ?? this.timeout,
      isLocked: isLocked ?? this.isLocked,
      supportedMethod: supportedMethod ?? this.supportedMethod,
      isHardwareSupported: isHardwareSupported ?? this.isHardwareSupported,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      lastUnlockedAt: lastUnlockedAt ?? this.lastUnlockedAt,
    );
  }

  @override
  List<Object?> get props => [
        isEnabled,
        timeout,
        isLocked,
        supportedMethod,
        isHardwareSupported,
        isAuthenticating,
        lastUnlockedAt,
      ];
}

class BiometricNotifier extends StateNotifier<BiometricState> {
  final BiometricRepository _repository;
  final BiometricService _biometricService;

  BiometricNotifier({
    required BiometricRepository repository,
    required BiometricService biometricService,
  })  : _repository = repository,
        _biometricService = biometricService,
        super(const BiometricState(
          isEnabled: false,
          timeout: BiometricTimeout.immediately,
          isLocked: false,
          supportedMethod: 'Checking...',
          isHardwareSupported: false,
        )) {
    init();
  }

  Future<void> init() async {
    final isSupported = await _repository.isDeviceSupported();
    final canCheck = await _repository.canCheckBiometrics();
    final isHardwareSupported = isSupported && canCheck;

    final method = await _biometricService.getCapabilityStatus();
    final isEnabled = await _repository.isBiometricEnabled();
    final timeout = await _repository.getTimeout();
    final lastUnlocked = await _repository.getLastUnlockedAt();

    bool isLocked = false;
    if (isEnabled) {
      if (lastUnlocked == null) {
        isLocked = true;
      } else if (timeout != BiometricTimeout.never) {
        final elapsed = DateTime.now().difference(lastUnlocked);
        if (elapsed >= timeout.duration) {
          isLocked = true;
        }
      }
    }

    state = BiometricState(
      isEnabled: isEnabled,
      timeout: timeout,
      isLocked: isLocked,
      supportedMethod: method,
      isHardwareSupported: isHardwareSupported,
      lastUnlockedAt: lastUnlocked,
    );
  }

  Future<bool> authenticate() async {
    if (!state.isEnabled && !state.isLocked) return true;

    state = state.copyWith(isAuthenticating: true);
    final success = await _repository.authenticate(
      reason: 'Authenticate to access ArthiqHQ',
    );

    if (success) {
      final now = DateTime.now();
      await _repository.setLastUnlockedAt(now);
      state = state.copyWith(
        isLocked: false,
        isAuthenticating: false,
        lastUnlockedAt: now,
      );
      return true;
    } else {
      state = state.copyWith(isAuthenticating: false);
      return false;
    }
  }

  Future<String?> enableBiometric() async {
    // 1. Verify capability
    final isSupported = await _repository.isDeviceSupported();
    if (!isSupported) {
      return 'Device does not support biometric or credential security.';
    }

    final canCheck = await _repository.canCheckBiometrics();
    final available = await _repository.getAvailableBiometrics();
    if (!canCheck && available.isEmpty) {
      return 'No biometric or device credentials configured. Please set a lock screen PIN or fingerprint in device settings.';
    }

    // 2. Perform authentication first before enabling
    final success = await _repository.authenticate(
      reason: 'Confirm authentication to enable biometric lock',
    );

    if (success) {
      await _repository.setBiometricEnabled(true);
      final now = DateTime.now();
      await _repository.setLastUnlockedAt(now);
      state = state.copyWith(
        isEnabled: true,
        lastUnlockedAt: now,
        isLocked: false,
      );
      return null; // success
    } else {
      return 'Authentication failed. Could not enable biometric security.';
    }
  }

  Future<bool> disableBiometric() async {
    if (!state.isEnabled) return true;

    // Must authenticate to turn OFF
    final success = await _repository.authenticate(
      reason: 'Confirm authentication to disable biometric lock',
    );

    if (success) {
      await _repository.setBiometricEnabled(false);
      await _repository.setLastUnlockedAt(null);
      state = state.copyWith(
        isEnabled: false,
        lastUnlockedAt: null,
      );
      return true;
    }
    return false;
  }

  Future<void> updateTimeout(BiometricTimeout timeout) async {
    await _repository.setTimeout(timeout);
    state = state.copyWith(timeout: timeout);
  }

  Future<bool> testAuthentication() async {
    return await _repository.authenticate(
      reason: 'Testing biometric authentication',
    );
  }

  void lock() {
    if (state.isEnabled) {
      state = state.copyWith(isLocked: true);
    }
  }

  void unlock() {
    final now = DateTime.now();
    _repository.setLastUnlockedAt(now);
    state = state.copyWith(
      isLocked: false,
      lastUnlockedAt: now,
    );
  }

  void resetSession() {
    _repository.setLastUnlockedAt(null);
    state = state.copyWith(
      isLocked: false,
      lastUnlockedAt: null,
    );
  }

  Future<void> handleAppResumed(Duration elapsed) async {
    if (!state.isEnabled) return;
    if (state.isLocked) return;

    if (state.timeout == BiometricTimeout.never) {
      return;
    }

    final lastUnlocked = state.lastUnlockedAt;
    if (lastUnlocked == null) {
      lock();
      return;
    }

    final timeSinceUnlock = DateTime.now().difference(lastUnlocked);
    if (timeSinceUnlock >= state.timeout.duration) {
      lock();
    }
  }

  Future<void> checkAndResume() async {
    final lastUnlocked = await _repository.getLastUnlockedAt();
    if (lastUnlocked != null) {
      state = state.copyWith(lastUnlockedAt: lastUnlocked);
      final elapsed = DateTime.now().difference(lastUnlocked);
      if (state.isEnabled && state.timeout != BiometricTimeout.never && elapsed >= state.timeout.duration) {
        lock();
      }
    } else if (state.isEnabled) {
      lock();
    }
  }
}

final biometricProvider = StateNotifierProvider<BiometricNotifier, BiometricState>((ref) {
  final repo = locator<BiometricRepository>();
  final service = locator<BiometricService>();
  return BiometricNotifier(repository: repo, biometricService: service);
});
