import '../../../../core/common/result.dart';
import '../entities/category_entity.dart';

/// Contract definition for managing Categories.
abstract class CategoryRepository {
  Future<Result<List<CategoryEntity>>> getCategories();
}
