class UpdateAccountRequest {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final bool isActive;
  final int accountType;

  UpdateAccountRequest({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.isActive,
    required this.accountType,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "name": name,
      "description": description,
      "isActive": isActive,
      "accountType": accountType,
    };
  }
}