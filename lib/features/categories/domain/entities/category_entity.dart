class CategoryEntity {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final int categoryType;
  final bool isActive;
  final DateTime createdAt;

  const CategoryEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.categoryType,
    required this.isActive,
    required this.createdAt,
  });
}