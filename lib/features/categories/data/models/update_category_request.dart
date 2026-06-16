class UpdateCategoryRequest {
  final String id;
  final String name;
  final String description;
  final int categoryType;
  final bool isActive;

  UpdateCategoryRequest({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryType,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categoryType': categoryType,
      'isActive': isActive,
    };
  }
}