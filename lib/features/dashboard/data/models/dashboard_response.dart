import '../../domain/entities/dashboard_entity.dart';

class CategoryBreakdownResponse {
  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;

  const CategoryBreakdownResponse({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  factory CategoryBreakdownResponse.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownResponse(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  CategoryBreakdownItem toEntity() {
    return CategoryBreakdownItem(
      categoryId: categoryId,
      categoryName: categoryName,
      amount: amount,
      percentage: percentage,
    );
  }
}

class DashboardResponse {
  final String userId;
  final double totalBalance;
  final double totalIncome;
  final double totalSpent;
  final double totalSavings;
  final List<CategoryBreakdownResponse> expenseBreakdown;

  const DashboardResponse({
    required this.userId,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalSpent,
    required this.totalSavings,
    required this.expenseBreakdown,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      userId: json['userId'] as String,
      totalBalance: (json['totalBalance'] as num).toDouble(),
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalSpent: (json['totalSpent'] as num).toDouble(),
      totalSavings: (json['totalSavings'] as num).toDouble(),
      expenseBreakdown: (json['expenseBreakdown'] as List<dynamic>)
          .map((e) => CategoryBreakdownResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  DashboardSummaryEntity toEntity() {
    return DashboardSummaryEntity(
      totalBalance: totalBalance,
      totalIncome: totalIncome,
      totalSpent: totalSpent,
      totalSavings: totalSavings,
      expenseBreakdown: expenseBreakdown.map((e) => e.toEntity()).toList(),
    );
  }
}
