import 'package:expense_tracker/features/settings/application/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/storage/auth_storage.dart';

import '../../data/datasources/user_remote_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/user_entity.dart';

final userRepositoryProvider = Provider((ref) {
  final dio = DioProvider.createDio();
  final apiClient = ApiClient(dio);
  final dataSource = UserRemoteDataSource(apiClient);
  return UserRepositoryImpl(dataSource);
});

/// Provides the currently logged-in user's basic info from auth storage.
/// Falls back to API if needed (e.g. after edit profile).
final userProvider = FutureProvider<UserEntity>((ref) async {
  final storage = AuthStorage();

  // Try returning from stored auth data first (fast, no network needed)
  final fullName = await storage.getFullName();
  final email = await storage.getEmail();
  final userId = await storage.getUserId();

  if (fullName != null && email != null) {
    return UserEntity(
      id: userId ?? '',
      fullName: fullName,
      email: email,
    );
  }

  // Fallback: fetch from API using stored userId
  if (userId != null && userId.isNotEmpty) {
    final repository = ref.read(userRepositoryProvider);
    final result = await repository.getUserById(userId);
    return result.fold(
      (data) => data,
      (failure) => throw Exception(failure.message),
    );
  }

  throw Exception('Not authenticated');
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.read(userRepositoryProvider));
});
