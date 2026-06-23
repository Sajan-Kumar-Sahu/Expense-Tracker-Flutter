class CategoryRequest {
  final String name;
  final String? description;
  final int categoryType;

  CategoryRequest({
    required this.name,
    this.description,
    required this.categoryType,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'categoryType': categoryType,
    };
  }
}
