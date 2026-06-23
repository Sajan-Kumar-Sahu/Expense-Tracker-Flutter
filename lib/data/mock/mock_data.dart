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
      currentBalance: 1500,
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
      userId: 'user1',
      accountId: 'acc2',
      categoryId: 'cat_salary',
      amount: 85000,
      transactionType: 1, // Income
      transactionDate: DateTime(2024, 6, 1),
      party: '',
      notes: '',
      createdAt: DateTime(2024, 6, 1),
    ),
    TransactionEntity(
      id: 't2',
      userId: 'user1',
      accountId: 'acc4',
      categoryId: 'cat_subscription',
      amount: 499,
      transactionType: 2, // Expense
      transactionDate: DateTime(2024, 6, 3),
      party: 'Netflix',
      notes: 'Netflix Subscription',
      createdAt: DateTime(2024, 6, 3),
    ),
    TransactionEntity(
      id: 't3',
      userId: 'user1',
      accountId: 'acc1',
      categoryId: 'cat_food',
      amount: 1250,
      transactionType: 2, // Expense
      transactionDate: DateTime(2024, 6, 5),
      party: '',
      notes: 'Grocery Shopping',
      createdAt: DateTime(2024, 6, 5),
    ),
    TransactionEntity(
      id: 't4',
      userId: 'user1',
      accountId: 'acc1',
      categoryId: 'cat_food',
      amount: 680,
      transactionType: 2, // Expense
      transactionDate: DateTime(2024, 6, 7),
      party: '',
      notes: 'Restaurant Lunch',
      createdAt: DateTime(2024, 6, 7),
    ),
    TransactionEntity(
      id: 't5',
      userId: 'user1',
      accountId: 'acc3',
      categoryId: 'cat_shopping',
      amount: 2399,
      transactionType: 2, // Expense
      transactionDate: DateTime(2024, 6, 9),
      party: 'Amazon',
      notes: 'Amazon Purchase',
      createdAt: DateTime(2024, 6, 9),
    ),
    TransactionEntity(
      id: 't6',
      userId: 'user1',
      accountId: 'acc2',
      categoryId: 'cat_freelance',
      amount: 15000,
      transactionType: 1, // Income
      transactionDate: DateTime(2024, 6, 11),
      party: '',
      notes: 'Freelance Payment',
      createdAt: DateTime(2024, 6, 11),
    ),
    TransactionEntity(
      id: 't7',
      userId: 'user1',
      accountId: 'acc4',
      categoryId: 'cat_transport',
      amount: 850,
      transactionType: 2, // Expense
      transactionDate: DateTime(2024, 6, 12),
      party: 'Ola',
      notes: 'Ola Cab Rides',
      createdAt: DateTime(2024, 6, 12),
    ),
    TransactionEntity(
      id: 't8',
      userId: 'user1',
      accountId: 'acc1',
      categoryId: 'cat_utility',
      amount: 1800,
      transactionType: 2, // Expense
      transactionDate: DateTime(2024, 6, 13),
      party: '',
      notes: 'Electricity Bill',
      createdAt: DateTime(2024, 6, 13),
    ),
    TransactionEntity(
      id: 't9',
      userId: 'user1',
      accountId: 'acc3',
      categoryId: 'cat_health',
      amount: 3500,
      transactionType: 2, // Expense
      transactionDate: DateTime(2024, 6, 14),
      party: '',
      notes: 'Medical Checkup',
      createdAt: DateTime(2024, 6, 14),
    ),
    TransactionEntity(
      id: 't10',
      userId: 'user1',
      accountId: 'acc2',
      categoryId: 'cat_education',
      amount: 5000,
      transactionType: 2, // Expense
      transactionDate: DateTime(2024, 6, 15),
      party: '',
      notes: 'Online Course',
      createdAt: DateTime(2024, 6, 15),
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
