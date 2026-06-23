class UpdateAccountRequest {
  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final int accountType;

  UpdateAccountRequest({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.accountType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
      'accountType': accountType,
    };
  }
}
