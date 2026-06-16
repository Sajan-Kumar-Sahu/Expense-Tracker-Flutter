import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String userId;

  final String accountId;
  final String? transferAccountId;

  final String categoryId;

  /// 1 = Income
  /// 2 = Expense
  /// 3 = Transfer
  final int transactionType;

  final double amount;
  final DateTime transactionDate;

  final String paidTo;
  final String notes;

  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.accountId,
    this.transferAccountId,
    required this.categoryId,
    required this.transactionType,
    required this.amount,
    required this.transactionDate,
    required this.paidTo,
    required this.notes,
    required this.createdAt,
  });

  bool get isIncome => transactionType == 1;

  bool get isExpense => transactionType == 2;

  bool get isTransfer => transactionType == 3;

  @override
  List<Object?> get props => [
    id,
    userId,
    accountId,
    transferAccountId,
    categoryId,
    transactionType,
    amount,
    transactionDate,
    paidTo,
    notes,
    createdAt,
  ];
}