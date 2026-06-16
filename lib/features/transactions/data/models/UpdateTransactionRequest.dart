class UpdateTransactionRequest {
  final String id;

  final String accountId;
  final String? transferAccountId;
  final String? categoryId;

  final int transactionType;
  final double amount;

  final DateTime transactionDate;

  final String paidTo;
  final String notes;

  UpdateTransactionRequest({
    required this.id,
    required this.accountId,
    this.transferAccountId,
    this.categoryId,
    required this.transactionType,
    required this.amount,
    required this.transactionDate,
    required this.paidTo,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'transferAccountId': transferAccountId,
      'categoryId': categoryId,
      'transactionType': transactionType,
      'amount': amount,
      'transactionDate': transactionDate.toUtc().toIso8601String(),
      'paidTo': paidTo,
      'notes': notes,
    };
  }
}