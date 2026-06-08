import 'dart:ffi';

import '../../domain/entities/account_entity.dart';

class AccountResponse extends AccountEntity {
  const AccountResponse({
    required super.id,
    required super.userId,
    required super.name,
    super.description,
    required super.openingBalance,
    required super.isActive,
    required super.accountType,
    required super.createdAt,
  });

  factory AccountResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return AccountResponse(
      id: json["id"] as String,
      userId: json["userId"] as String,
      name: json["name"] as String,
      description: json["description"] as String,
      openingBalance:
      (json["openingBalance"] as num).toDouble(),
      isActive: json["isActive"] as bool,
      accountType: json["accountType"] as int,
      createdAt: DateTime.parse(json["createdAt"] as String),
    );
  }
}