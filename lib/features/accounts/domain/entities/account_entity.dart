class AccountEntity {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final double openingBalance;
  final bool isActive;
  final int accountType;
  final DateTime createdAt;

  const AccountEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.openingBalance,
    required this.isActive,
    required this.accountType,
    required this.createdAt,
  });
}