import 'package:equatable/equatable.dart';

class CategoryBreakdownItem extends Equatable {
  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;

  const CategoryBreakdownItem({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [categoryId, categoryName, amount, percentage];
}

class DashboardSummaryEntity extends Equatable {
  final double totalBalance;
  final double totalIncome;
  final double totalSpent;
  final double totalSavings;
  final List<CategoryBreakdownItem> expenseBreakdown;

  const DashboardSummaryEntity({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalSpent,
    required this.totalSavings,
    required this.expenseBreakdown,
  });

  @override
  List<Object?> get props => [
        totalBalance,
        totalIncome,
        totalSpent,
        totalSavings,
        expenseBreakdown,
      ];
}
