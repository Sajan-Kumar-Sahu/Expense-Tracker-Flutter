import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dashboard_entity.dart';

/// Skeleton notifier for Dashboard state management.
class DashboardNotifier extends AsyncNotifier<DashboardSummaryEntity> {
  @override
  FutureOr<DashboardSummaryEntity> build() async {
    return const DashboardSummaryEntity(
      totalBalance: 0.00,
      totalIncome: 0.00,
      totalExpense: 0.00,
      recentTransactions: [],
    );
  }
}

/// App-wide provider for Dashboard summary data.
final dashboardProvider = AsyncNotifierProvider<DashboardNotifier, DashboardSummaryEntity>(() {
  return DashboardNotifier();
});
