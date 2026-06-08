import 'package:expense_tracker/features/settings/application/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/common/result.dart';

import '../../data/datasources/user_remote_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/user_entity.dart';

final userRepositoryProvider = Provider((ref) {
  final dio = DioProvider.createDio();

  final apiClient = ApiClient(dio);

  final dataSource = UserRemoteDataSource(apiClient);

  return UserRepositoryImpl(dataSource);
});

final userProvider = FutureProvider<UserEntity>((ref) async {
  const userId = '94623bcb-fed5-47a0-a684-720dd84fcbe9';

  final repository = ref.read(userRepositoryProvider);

  final result = await repository.getUserById(userId);

  return result.fold(
        (data) => data,
        (failure) => throw Exception(failure.message),
  );
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(
    ref.read(userRepositoryProvider),
  );
});