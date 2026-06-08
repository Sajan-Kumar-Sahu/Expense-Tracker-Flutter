import 'package:equatable/equatable.dart';

/// Immutable domain model representing dashboard summaries and account balances.
class DashboardSummaryEntity extends Equatable {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final List<dynamic> recentTransactions;

  const DashboardSummaryEntity({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [
        totalBalance,
        totalIncome,
        totalExpense,
        recentTransactions,
      ];
}
