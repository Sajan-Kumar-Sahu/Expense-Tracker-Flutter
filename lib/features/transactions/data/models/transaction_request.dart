class TransactionRequest {
  final String accountId;
  final String? transferAccountId;
  final String? categoryId;
  final int transactionType;
  final double amount;
  final DateTime transactionDate;
  final String party;
  final String notes;

  TransactionRequest({
    required this.accountId,
    this.transferAccountId,
    required this.categoryId,
    required this.transactionType,
    required this.amount,
    required this.transactionDate,
    required this.party,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'accountId': accountId,
      'categoryId': categoryId,
      'transactionType': transactionType,
      'amount': amount,
      'transactionDate': DateTime.utc(transactionDate.year, transactionDate.month, transactionDate.day).toIso8601String(),
      'party': party,
      'notes': notes,
    };

    if (transferAccountId != null && transferAccountId!.isNotEmpty) {
      json['transferAccountId'] = transferAccountId;
    }

    return json;
  }
}
