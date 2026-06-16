import '../../domain/entities/auth_entity.dart';

class AuthResponseModel extends AuthEntity {
  const AuthResponseModel({
    required super.accessToken,
    required super.refreshToken,
    required super.expiresAt,
    required super.fullName,
    required super.email,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      fullName: json['fullName'] as String,
      email: json['email'] as String,
    );
  }
}
