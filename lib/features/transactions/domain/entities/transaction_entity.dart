import 'package:equatable/equatable.dart';

/// Immutable domain model representing a financial transaction.
class TransactionEntity extends Equatable {
  final String id;
  final String accountId;
  final String categoryId;
  final double amount;
  final String description;
  final String transactionType; // e.g. income, expense
  final DateTime transactionDate;

  const TransactionEntity({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.transactionType,
    required this.transactionDate,
  });

  @override
  List<Object?> get props => [
        id,
        accountId,
        categoryId,
        amount,
        description,
        transactionType,
        transactionDate,
      ];
}
