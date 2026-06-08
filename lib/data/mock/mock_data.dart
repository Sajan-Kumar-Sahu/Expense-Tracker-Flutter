import '../../features/accounts/domain/entities/account_entity.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';

/// Realistic mock data for Indian rupee-based finance app.
class MockData {
  MockData._();

  // ------------------------------------------------------------------
  // Mock user
  // ------------------------------------------------------------------
  static const String userName = 'Arjun Sharma';
  static const String userEmail = 'arjun.sharma@example.com';
  static const String userInitials = 'AS';

  // ------------------------------------------------------------------
  // Financial summary
  // ------------------------------------------------------------------
  static const double totalBalance = 125000;
  static const double totalIncome = 85000;
  static const double totalExpenses = 35000;
  static const double totalSavings = 50000;

  // ------------------------------------------------------------------
  // Mock accounts
  // ------------------------------------------------------------------
  static final List<AccountEntity> accounts = [
    AccountEntity(
      id: '1',
      userId: 'mock-user',
      name: 'Cash Wallet',
      description: 'Mock Account',
      openingBalance: 1500,
      isActive: true,
      accountType: 2,
      createdAt: DateTime.now(),
    )
  ];

  // ------------------------------------------------------------------
  // Mock transactions
  // ------------------------------------------------------------------
  static final List<TransactionEntity> transactions = [
    TransactionEntity(
      id: 't1',
      accountId: 'acc2',
      categoryId: 'cat_salary',
      amount: 85000,
      description: 'Monthly Salary',
      transactionType: 'income',
      transactionDate: DateTime(2024, 6, 1),
    ),
    TransactionEntity(
      id: 't2',
      accountId: 'acc4',
      categoryId: 'cat_subscription',
      amount: 499,
      description: 'Netflix Subscription',
      transactionType: 'expense',
      transactionDate: DateTime(2024, 6, 3),
    ),
    TransactionEntity(
      id: 't3',
      accountId: 'acc1',
      categoryId: 'cat_food',
      amount: 1250,
      description: 'Grocery Shopping',
      transactionType: 'expense',
      transactionDate: DateTime(2024, 6, 5),
    ),
    TransactionEntity(
      id: 't4',
      accountId: 'acc1',
      categoryId: 'cat_food',
      amount: 680,
      description: 'Restaurant Lunch',
      transactionType: 'expense',
      transactionDate: DateTime(2024, 6, 7),
    ),
    TransactionEntity(
      id: 't5',
      accountId: 'acc3',
      categoryId: 'cat_shopping',
      amount: 2399,
      description: 'Amazon Purchase',
      transactionType: 'expense',
      transactionDate: DateTime(2024, 6, 9),
    ),
    TransactionEntity(
      id: 't6',
      accountId: 'acc2',
      categoryId: 'cat_freelance',
      amount: 15000,
      description: 'Freelance Payment',
      transactionType: 'income',
      transactionDate: DateTime(2024, 6, 11),
    ),
    TransactionEntity(
      id: 't7',
      accountId: 'acc4',
      categoryId: 'cat_transport',
      amount: 850,
      description: 'Ola Cab Rides',
      transactionType: 'expense',
      transactionDate: DateTime(2024, 6, 12),
    ),
    TransactionEntity(
      id: 't8',
      accountId: 'acc1',
      categoryId: 'cat_utility',
      amount: 1800,
      description: 'Electricity Bill',
      transactionType: 'expense',
      transactionDate: DateTime(2024, 6, 13),
    ),
    TransactionEntity(
      id: 't9',
      accountId: 'acc3',
      categoryId: 'cat_health',
      amount: 3500,
      description: 'Medical Checkup',
      transactionType: 'expense',
      transactionDate: DateTime(2024, 6, 14),
    ),
    TransactionEntity(
      id: 't10',
      accountId: 'acc2',
      categoryId: 'cat_education',
      amount: 5000,
      description: 'Online Course',
      transactionType: 'expense',
      transactionDate: DateTime(2024, 6, 15),
    ),
  ];

  // ------------------------------------------------------------------
  // Analytics breakdown (expense by category %)
  // ------------------------------------------------------------------
  static final List<AnalyticsCategory> analyticsCategories = [
    AnalyticsCategory(label: 'Food', percentage: 32, colorHex: 0xFF6366F1),
    AnalyticsCategory(label: 'Shopping', percentage: 24, colorHex: 0xFF10B981),
    AnalyticsCategory(label: 'Transport', percentage: 18, colorHex: 0xFFF59E0B),
    AnalyticsCategory(label: 'Health', percentage: 14, colorHex: 0xFFEF4444),
    AnalyticsCategory(label: 'Others', percentage: 12, colorHex: 0xFF8B5CF6),
  ];
}

class AnalyticsCategory {
  final String label;
  final double percentage;
  final int colorHex;

  const AnalyticsCategory({
    required this.label,
    required this.percentage,
    required this.colorHex,
  });
}
