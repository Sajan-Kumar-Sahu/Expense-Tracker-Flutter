import '../../domain/entities/transaction_entity.dart';

class TransactionResponse {
  final String id;
  final String userId;
  final String accountId;
  final String? transferAccountId;
  final String categoryId;
  final int transactionType;
  final double amount;
  final DateTime transactionDate;
  final String? paidTo;
  final String? notes;
  final DateTime createdAt;

  TransactionResponse({
    required this.id,
    required this.userId,
    required this.accountId,
    this.transferAccountId,
    required this.categoryId,
    required this.transactionType,
    required this.amount,
    required this.transactionDate,
    this.paidTo,
    this.notes,
    required this.createdAt,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      id: json['id'] as String,
      userId: json['userId'] as String,
      accountId: json['accountId'] as String,
      transferAccountId: json['transferAccountId'] as String?,
      categoryId: json['categoryId']as String,
      transactionType: json['transactionType'] as int,
      amount: (json['amount'] as num).toDouble(),
      transactionDate: DateTime.parse(json['transactionDate']as String),
      paidTo: json['paidTo'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt']as String),
    );
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      userId: userId,
      accountId: accountId,
      transferAccountId: transferAccountId,
      categoryId: categoryId,
      transactionType: transactionType,
      amount: amount,
      transactionDate: transactionDate,
      paidTo: paidTo ?? '',
      notes: notes ?? '',
      createdAt: createdAt,
    );
  }

  String _mapType(int type) {
    switch (type) {
      case 1:
        return 'income';
      case 2:
        return 'expense';
      case 3:
        return 'transfer';
      default:
        return 'expense';
    }
  }
}