import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Pages
import '../features/splash/presentation/pages/splash_page.dart';
import '../core/navigation/main_scaffold.dart';
import '../features/accounts/presentation/pages/add_edit_account_page.dart';

// Entities
import '../features/accounts/domain/entities/account_entity.dart';

/// Central router management.
class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String home = '/home';
  static const String addAccount = '/home/accounts/add';
  static const String editAccount = '/home/accounts/edit';

  // Legacy routes kept for backward compatibility
  static const String dashboard = '/home';
  static const String accounts = '/home';
  static const String categories = '/home';
  static const String transactions = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text(
          'Route not found: ${state.uri.path}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const MainScaffold(),
        routes: [
          GoRoute(
            path: 'accounts/add',
            builder: (context, state) => const AddEditAccountPage(),
          ),
          GoRoute(
            path: 'accounts/edit',
            builder: (context, state) {
              final account = state.extra as AccountEntity?;
              return AddEditAccountPage(account: account);
            },
          ),
        ],
      ),
    ],
  );
}
