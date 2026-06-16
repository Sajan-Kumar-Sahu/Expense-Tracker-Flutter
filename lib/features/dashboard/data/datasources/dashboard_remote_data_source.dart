import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/dashboard_response.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardResponse> getDashboard();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl(this.apiClient);

  @override
  Future<DashboardResponse> getDashboard() async {
    final response = await apiClient.get(ApiEndpoints.dashboard);

    return DashboardResponse.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
