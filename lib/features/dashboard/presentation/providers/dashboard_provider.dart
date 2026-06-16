import 'dart:async';

import 'package:expense_tracker/dependency_injection/injection.dart';
import 'package:expense_tracker/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/settings/presentation/providers/user_provider.dart';
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
  final user = await ref.watch(userProvider.future);
  final dataSource = locator<TransactionRemoteDataSource>();
  final responses = await dataSource.getTransactions(user.id);
  return responses.map((r) => r.toEntity()).take(5).toList();
});
