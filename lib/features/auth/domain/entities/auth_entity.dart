import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String fullName;
  final String email;

  const AuthEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.fullName,
    required this.email,
  });

  @override
  List<Object?> get props =>
      [accessToken, refreshToken, expiresAt, fullName, email];
}
