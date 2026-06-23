import 'dart:async';

import 'package:expense_tracker/dependency_injection/injection.dart';
import 'package:expense_tracker/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dashboard_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardNotifier extends AsyncNotifier<DashboardSummaryEntity> {
  @override
  FutureOr<DashboardSummaryEntity> build() async {
    final repository = locator<DashboardRepository>();
    final result = await repository.getSummary();

    return result.fold(
      (data) => data,
      (failure) => throw Exception(failure.message),
    );
  }
}

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardSummaryEntity>(
  () => DashboardNotifier(),
);

/// Controls whether the balance amounts are visible or blurred.
final balanceVisibleProvider = StateProvider<bool>((ref) => false);

/// Fetches the 5 most recent transactions for the current user.
final recentTransactionsProvider =
    FutureProvider<List<TransactionEntity>>((ref) async {
  final dataSource = locator<TransactionRemoteDataSource>();
  final paged = await dataSource.getTransactions(page: 1, pageSize: 5);
  return paged.items.map((r) => r.toEntity()).toList();
});
