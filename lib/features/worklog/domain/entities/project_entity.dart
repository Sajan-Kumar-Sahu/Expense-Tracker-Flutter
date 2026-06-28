class ProjectEntity {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProjectEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });
}
