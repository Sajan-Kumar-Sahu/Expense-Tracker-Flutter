class CategoryRequest {
  final String userId;
  final String name;
  final String? description;
  final int categoryType;

  CategoryRequest({
    required this.userId,
    required this.name,
    this.description,
    required this.categoryType,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'categoryType': categoryType,
    };
  }
}