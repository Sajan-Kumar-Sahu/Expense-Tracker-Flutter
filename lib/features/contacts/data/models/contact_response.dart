import '../../domain/entities/contact_entity.dart';

class ContactResponse {
  final String id;
  final String userId;
  final String name;
  final String? mobileNumber;
  final String? email;
  final int contactType;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;

  ContactResponse({
    required this.id,
    required this.userId,
    required this.name,
    this.mobileNumber,
    this.email,
    required this.contactType,
    required this.isActive,
    this.notes,
    required this.createdAt,
  });

  factory ContactResponse.fromJson(Map<String, dynamic> json) {
    return ContactResponse(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      mobileNumber: json['mobileNumber'] as String?,
      email: json['email'] as String?,
      contactType: json['contactType'] as int,
      isActive: json['isActive'] as bool,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  ContactEntity toEntity() {
    return ContactEntity(
      id: id,
      userId: userId,
      name: name,
      mobileNumber: mobileNumber,
      email: email,
      contactType: contactType,
      isActive: isActive,
      notes: notes,
      createdAt: createdAt,
    );
  }
}
