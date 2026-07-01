import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/biometric/presentation/providers/biometric_provider.dart';

import '../../features/accounts/presentation/providers/accounts_provider.dart';
import '../../features/categories/presentation/providers/categories_provider.dart';
import '../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../features/settings/presentation/providers/user_provider.dart';
import '../../features/transactions/presentation/providers/transactions_provider.dart';
import '../../features/reminders/presentation/providers/reminder_provider.dart';
import '../../features/reminders/presentation/providers/notification_provider.dart';

/// Call after any create / update / delete and on app resume.
/// Refreshes every data provider so the UI is always consistent.
Future<void> refreshAll(WidgetRef ref) async {
  ref.invalidate(userProvider);
  await Future.wait([
    ref.read(accountsProvider).loadAccounts(),
    ref.read(categoriesProvider).loadCategories(),
    ref.read(transactionsProvider).loadTransactions(),
  ]);
  ref.invalidate(dashboardProvider);
  ref.invalidate(recentTransactionsProvider);
}

/// Call on logout — immediately clears all in-memory data so stale state
/// from the previous user is never visible after the next login.
void clearAll(WidgetRef ref) {
  ref.read(accountsProvider).reset();
  ref.read(categoriesProvider).reset();
  ref.read(transactionsProvider).reset();
  ref.read(reminderProvider).reset();
  ref.read(notificationProvider).reset();
  ref.invalidate(dashboardProvider);
  ref.invalidate(recentTransactionsProvider);
  ref.invalidate(userProvider);
  ref.read(biometricProvider.notifier).resetSession();
}
