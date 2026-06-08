import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category_entity.dart';

/// Skeleton notifier for Categories state management.
class CategoriesNotifier extends AsyncNotifier<List<CategoryEntity>> {
  @override
  FutureOr<List<CategoryEntity>> build() async {
    return [];
  }
}

/// App-wide provider for Category state.
final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier, List<CategoryEntity>>(() {
  return CategoriesNotifier();
});
