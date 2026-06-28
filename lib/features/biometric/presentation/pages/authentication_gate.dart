import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/biometric_provider.dart';
import 'lock_screen.dart';

class AuthenticationGate extends ConsumerWidget {
  final Widget child;

  const AuthenticationGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final biometricState = ref.watch(biometricProvider);

    // Only intercept when user is fully authenticated, has enabled biometrics, and is currently locked
    if (authState is AuthAuthenticated &&
        biometricState.isEnabled &&
        biometricState.isLocked) {
      return const LockScreen();
    }

    return child;
  }
}
