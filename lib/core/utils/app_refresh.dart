import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/accounts/presentation/providers/accounts_provider.dart';
import '../../features/categories/presentation/providers/categories_provider.dart';
import '../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../features/transactions/presentation/providers/transactions_provider.dart';

/// Call after any create / update / delete and on app resume.
/// Refreshes every data provider so the UI is always consistent.
Future<void> refreshAll(WidgetRef ref) async {
  await Future.wait([
    ref.read(accountsProvider).loadAccounts(),
    ref.read(categoriesProvider).loadCategories(),
    ref.read(transactionsProvider).loadTransactions(),
  ]);
  ref.invalidate(dashboardProvider);
  ref.invalidate(recentTransactionsProvider);
}
