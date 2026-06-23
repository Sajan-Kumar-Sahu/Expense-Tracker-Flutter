import 'package:expense_tracker/features/categories/data/models/category_request.dart';
import 'package:expense_tracker/features/categories/data/models/category_response.dart';
import 'package:expense_tracker/features/categories/data/models/update_category_request.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryResponse>> getCategories();

  Future<CategoryResponse> createCategory(CategoryRequest request);

  Future<CategoryResponse> updateCategory(UpdateCategoryRequest request);

  Future<void> deleteCategory(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient apiClient;

  CategoryRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<CategoryResponse>> getCategories() async {
    final response = await apiClient.get(ApiEndpoints.categories);

    return (response.data['data'] as List<dynamic>)
        .map((json) => CategoryResponse.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CategoryResponse> createCategory(CategoryRequest request) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.categories,
      data: request.toJson(),
    );

    return CategoryResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<CategoryResponse> updateCategory(UpdateCategoryRequest request) async {
    final response = await apiClient.patch(
      '${ApiEndpoints.categories}/${request.id}',
      data: request.toJson(),
    );

    return CategoryResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    await apiClient.delete('${ApiEndpoints.categories}/$id');
  }
}
