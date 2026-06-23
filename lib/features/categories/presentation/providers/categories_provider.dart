import 'package:expense_tracker/dependency_injection/injection.dart';
import 'package:expense_tracker/features/categories/data/models/update_category_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category_request.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';

class CategoriesProvider extends ChangeNotifier {
  final CategoryRepository repository;

  CategoriesProvider(this.repository) {
    loadCategories();
  }

  bool isLoading = false;
  List<CategoryEntity> categories = [];

  Future<void> loadCategories() async {
    try {
      isLoading = true;
      notifyListeners();

      categories = await repository.getCategories();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCategory(CategoryRequest request) async {
    try {
      isLoading = true;
      notifyListeners();

      final category = await repository.createCategory(request);
      categories.add(category);

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCategory(UpdateCategoryRequest request) async {
    try {
      isLoading = true;
      notifyListeners();

      final updatedCategory = await repository.updateCategory(request);

      final index = categories.indexWhere((e) => e.id == updatedCategory.id);
      if (index != -1) {
        categories[index] = updatedCategory;
      }

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      isLoading = true;
      notifyListeners();

      await repository.deleteCategory(id);
      categories.removeWhere((e) => e.id == id);

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    categories = [];
    isLoading = false;
    notifyListeners();
  }
}

final categoriesProvider = ChangeNotifierProvider<CategoriesProvider>((ref) {
  return CategoriesProvider(locator<CategoryRepository>());
});
