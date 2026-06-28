import 'package:expense_tracker/core/constants/api_endpoints.dart';
import 'package:expense_tracker/core/network/api_client.dart';
import '../models/settlement_response.dart';

abstract class SettlementRemoteDataSource {
  Future<List<SettlementListResponse>> getSettlements();
  Future<List<SettlementListResponse>> getReceivables();
  Future<List<SettlementListResponse>> getPayables();
  Future<SettlementResponse> getSettlementById(String id);
  Future<SettlementSummaryResponse> getSummary();
  Future<SettlementResponse> createSettlement(Map<String, dynamic> data);
  Future<SettlementResponse> updateSettlement(String id, Map<String, dynamic> data);
  Future<void> deleteSettlement(String id);
  Future<SettlementResponse> receivePayment(String id, Map<String, dynamic> data);
  Future<SettlementResponse> pay(String id, Map<String, dynamic> data);
  Future<SettlementResponse> cancel(String id);
}

class SettlementRemoteDataSourceImpl implements SettlementRemoteDataSource {
  final ApiClient apiClient;

  SettlementRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<SettlementListResponse>> getSettlements() async {
    final response = await apiClient.get(ApiEndpoints.settlements);
    final List<dynamic> list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => SettlementListResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SettlementListResponse>> getReceivables() async {
    final response =
        await apiClient.get('${ApiEndpoints.settlements}/receivables');
    final List<dynamic> list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => SettlementListResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SettlementListResponse>> getPayables() async {
    final response =
        await apiClient.get('${ApiEndpoints.settlements}/payables');
    final List<dynamic> list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => SettlementListResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SettlementResponse> getSettlementById(String id) async {
    final response =
        await apiClient.get('${ApiEndpoints.settlements}/$id');
    return SettlementResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<SettlementSummaryResponse> getSummary() async {
    final response =
        await apiClient.get('${ApiEndpoints.settlements}/summary');
    return SettlementSummaryResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<SettlementResponse> createSettlement(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiEndpoints.settlements, data: data);
    return SettlementResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<SettlementResponse> updateSettlement(
      String id, Map<String, dynamic> data) async {
    final response =
        await apiClient.put('${ApiEndpoints.settlements}/$id', data: data);
    return SettlementResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteSettlement(String id) async {
    await apiClient.delete('${ApiEndpoints.settlements}/$id');
  }

  @override
  Future<SettlementResponse> receivePayment(
      String id, Map<String, dynamic> data) async {
    final response = await apiClient.post(
      '${ApiEndpoints.settlements}/$id/receive',
      data: data,
    );
    return SettlementResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<SettlementResponse> pay(String id, Map<String, dynamic> data) async {
    final response = await apiClient.post(
      '${ApiEndpoints.settlements}/$id/pay',
      data: data,
    );
    return SettlementResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<SettlementResponse> cancel(String id) async {
    final response = await apiClient.post(
      '${ApiEndpoints.settlements}/$id/cancel',
    );
    return SettlementResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }
}
