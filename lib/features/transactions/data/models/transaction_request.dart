class TransactionRequest {
  final String userId;
  final String accountId;
  final String? transferAccountId;
  final String? categoryId;
  final int transactionType;
  final double amount;
  final DateTime transactionDate;
  final String paidTo;
  final String notes;

  TransactionRequest({
    required this.userId,
    required this.accountId,
    this.transferAccountId,
    required this.categoryId,
    required this.transactionType,
    required this.amount,
    required this.transactionDate,
    required this.paidTo,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'userId': userId,
      'accountId': accountId,
      'categoryId': categoryId,
      'transactionType': transactionType,
      'amount': amount,
      'transactionDate': transactionDate.toUtc().toIso8601String(),
      'paidTo': paidTo,
      'notes': notes,
    };

    if (transferAccountId != null &&
        transferAccountId!.isNotEmpty) {
      json['transferAccountId'] =
          transferAccountId;
    }

    return json;
  }
}