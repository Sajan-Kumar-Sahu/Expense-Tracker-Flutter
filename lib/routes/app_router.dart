import 'package:expense_tracker/features/auth/presentation/pages/get_started_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/presentation/pages/add_edit_transaction_page.dart';
import 'package:expense_tracker/features/transactions/presentation/pages/transaction_details_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Pages
import '../features/splash/presentation/pages/splash_page.dart';
import '../core/navigation/main_scaffold.dart';
import '../features/accounts/presentation/pages/add_edit_account_page.dart';
import '../features/categories/presentation/pages/add_edit_category_page.dart';

// Entities
import '../features/accounts/domain/entities/account_entity.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String getStarted = '/get-started';
  static const String login = '/login';
  static const String home = '/home';

  static const String addAccount = '/home/accounts/add';
  static const String editAccount = '/home/accounts/edit';

  static const String addCategory = '/home/categories/add';
  static const String editCategory = '/home/categories/edit';

  static const String addTransaction = '/home/transactions/add';
  static const String editTransaction = '/home/transactions/edit';

  static const transactionDetails = '/home/transactions/details';

  static final GoRouter router = GoRouter(
    initialLocation: splash,

    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Route not found: ${state.uri.path}'),
      ),
    ),

    routes: [
      // Splash
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashPage(),
      ),

      // Auth
      GoRoute(
        path: getStarted,
        builder: (context, state) => const GetStartedPage(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
      ),

      // Main App
      GoRoute(
        path: home,
        builder: (context, state) => const MainScaffold(),
      ),

      // Accounts
      GoRoute(
        path: addAccount,
        builder: (context, state) => const AddEditAccountPage(),
      ),
      GoRoute(
        path: editAccount,
        builder: (context, state) {
          final account = state.extra as AccountEntity?;
          return AddEditAccountPage(account: account);
        },
      ),

      // Categories
      GoRoute(
        path: addCategory,
        builder: (context, state) => const AddEditCategoryPage(),
      ),
      GoRoute(
        path: editCategory,
        builder: (context, state) {
          final category = state.extra as CategoryEntity?;
          return AddEditCategoryPage(category: category);
        },
      ),

      // Transactions
      GoRoute(
        path: addTransaction,
        builder: (context, state) => AddEditTransactionPage(
          initialTransactionType: state.extra as int?,
        ),
      ),
      GoRoute(
        path: editTransaction,
        builder: (context, state) {
          final transaction = state.extra as TransactionEntity?;
          return AddEditTransactionPage(transaction: transaction);
        },
      ),
      GoRoute(
        path: transactionDetails,
        builder: (context, state) {
          final id = state.extra as String;
          return TransactionDetailsPage(transactionId: id);
        },
      ),
    ],
  );
}
