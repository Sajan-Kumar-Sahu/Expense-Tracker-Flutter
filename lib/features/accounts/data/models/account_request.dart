class AccountRequest {
  final String name;
  final String? description;
  final double openingBalance;
  final int accountType;

  AccountRequest({
    required this.name,
    this.description,
    required this.openingBalance,
    required this.accountType,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'openingBalance': openingBalance,
      'accountType': accountType,
    };
  }
}
