import 'package:equatable/equatable.dart';

class ContactEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? mobileNumber;
  final String? email;

  /// 1=Friend, 2=Family, 3=Business, 4=Platform, 5=Other
  final int contactType;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;

  const ContactEntity({
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

  String get contactTypeName {
    switch (contactType) {
      case 1:
        return 'Friend';
      case 2:
        return 'Family';
      case 3:
        return 'Business';
      case 4:
        return 'Platform';
      default:
        return 'Other';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        mobileNumber,
        email,
        contactType,
        isActive,
        notes,
        createdAt,
      ];
}
