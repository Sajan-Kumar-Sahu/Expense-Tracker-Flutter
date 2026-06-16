import 'package:expense_tracker/features/categories/data/models/category_request.dart';
import 'package:expense_tracker/features/categories/data/models/update_category_request.dart';

import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories(
      String userId,
      );

  Future<CategoryEntity> createCategory(
      CategoryRequest request,
      );

  Future<CategoryEntity> updateCategory(
      UpdateCategoryRequest request,
      );

  Future<void> deleteCategory(
      String id,
      );
}