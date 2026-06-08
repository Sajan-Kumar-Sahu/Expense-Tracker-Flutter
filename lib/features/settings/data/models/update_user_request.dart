class UpdateUserRequest {
  final String fullName;
  final String email;

  const UpdateUserRequest({
    required this.fullName,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
    };
  }
}