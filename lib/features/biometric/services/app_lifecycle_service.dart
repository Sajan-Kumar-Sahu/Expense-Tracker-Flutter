import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/biometric_provider.dart';

class AppLifecycleService extends WidgetsBindingObserver {
  final WidgetRef _ref;
  DateTime? _pausedTime;

  AppLifecycleService(this._ref);

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final biometricState = _ref.read(biometricProvider);
    final biometricNotifier = _ref.read(biometricProvider.notifier);

    if (!biometricState.isEnabled) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        if (_pausedTime == null) {
          _pausedTime = DateTime.now();
        }
        break;
      case AppLifecycleState.resumed:
        if (_pausedTime != null) {
          final elapsed = DateTime.now().difference(_pausedTime!);
          _pausedTime = null;
          biometricNotifier.handleAppResumed(elapsed);
        } else {
          biometricNotifier.checkAndResume();
        }
        break;
      case AppLifecycleState.detached:
        break;
      default:
        break;
    }
  }
}
