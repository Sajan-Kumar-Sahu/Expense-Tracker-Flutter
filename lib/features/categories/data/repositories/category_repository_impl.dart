import 'package:expense_tracker/features/categories/data/models/category_request.dart';
import 'package:expense_tracker/features/categories/data/models/update_category_request.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';

import '../datasources/category_remote_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remote;

  CategoryRepositoryImpl(this.remote);

  @override
  Future<List<CategoryEntity>> getCategories() {
    return remote.getCategories();
  }

  @override
  Future<CategoryEntity> createCategory(CategoryRequest request) {
    return remote.createCategory(request);
  }

  @override
  Future<CategoryEntity> updateCategory(UpdateCategoryRequest request) async {
    return await remote.updateCategory(request);
  }

  @override
  Future<void> deleteCategory(String id) {
    return remote.deleteCategory(id);
  }
}
