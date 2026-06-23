import '../../domain/entities/transaction_entity.dart';

class TransactionResponse {
  final String id;
  final String userId;
  final String accountId;
  final String? transferAccountId;
  final String? categoryId;
  final int transactionType;
  final double amount;
  final DateTime transactionDate;
  final String? party;
  final String? notes;
  final DateTime createdAt;

  TransactionResponse({
    required this.id,
    required this.userId,
    required this.accountId,
    this.transferAccountId,
    this.categoryId,
    required this.transactionType,
    required this.amount,
    required this.transactionDate,
    this.party,
    this.notes,
    required this.createdAt,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      id: json['id'] as String,
      userId: json['userId'] as String,
      accountId: json['accountId'] as String,
      transferAccountId: json['transferAccountId'] as String?,
      categoryId: json['categoryId'] as String?,
      transactionType: json['transactionType'] as int,
      amount: (json['amount'] as num).toDouble(),
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      party: json['party'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      userId: userId,
      accountId: accountId,
      transferAccountId: transferAccountId,
      categoryId: categoryId ?? '',
      transactionType: transactionType,
      amount: amount,
      transactionDate: transactionDate,
      party: party ?? '',
      notes: notes ?? '',
      createdAt: createdAt,
    );
  }
}
