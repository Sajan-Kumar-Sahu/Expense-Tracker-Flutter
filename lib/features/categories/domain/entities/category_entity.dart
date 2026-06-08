import 'package:equatable/equatable.dart';

/// Immutable domain model representing a transaction category (e.g. Food, Utilities).
class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String color;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [id, name, icon, color];
}
