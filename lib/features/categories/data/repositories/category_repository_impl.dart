import '../../../../core/common/result.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';

/// Skeleton implementation of the CategoryRepository contract.
class CategoryRepositoryImpl implements CategoryRepository {
  @override
  Future<Result<List<CategoryEntity>>> getCategories() async {
    return const Success([]);
  }
}
