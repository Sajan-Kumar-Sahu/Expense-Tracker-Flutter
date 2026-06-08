import 'package:expense_tracker/features/settings/data/models/update_user_request.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class UserRemoteDataSource {
  final ApiClient _client;

  UserRemoteDataSource(this._client);

  Future<UserModel> getUserById(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '${ApiEndpoints.users}/$id',
    );

    return UserModel.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  Future<UserModel> updateUser(
      String id,
      UpdateUserRequest request,
      ) async {
    final response =
    await _client.patch<Map<String, dynamic>>(
      '${ApiEndpoints.users}/$id',
      data: request.toJson(),
    );

    return UserModel.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }
}