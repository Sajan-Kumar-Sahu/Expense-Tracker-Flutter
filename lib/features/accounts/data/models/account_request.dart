class AccountRequest {
  final String userId;
  final String name;
  final String? description;
  final double openingBalance;
  final int accountType;

  AccountRequest({
    required this.userId,
    required this.name,
    this.description,
    required this.openingBalance,
    required this.accountType,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "name": name,
      "description": description,
      "openingBalance": openingBalance,
      "accountType": accountType,
    };
  }
}