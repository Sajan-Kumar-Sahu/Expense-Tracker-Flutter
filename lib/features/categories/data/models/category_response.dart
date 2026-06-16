import '../../domain/entities/category_entity.dart';

class CategoryResponse extends CategoryEntity {
  const CategoryResponse({
    required super.id,
    required super.userId,
    required super.name,
    super.description,
    required super.categoryType,
    required super.isActive,
    required super.createdAt,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description']as String?,
      categoryType: json['categoryType'] as int,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}