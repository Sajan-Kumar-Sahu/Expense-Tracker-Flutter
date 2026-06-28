import 'package:expense_tracker/core/constants/api_endpoints.dart';
import 'package:expense_tracker/core/network/api_client.dart';
import '../models/contact_response.dart';

abstract class ContactRemoteDataSource {
  Future<List<ContactResponse>> getContacts();
  Future<ContactResponse> getContactById(String id);
  Future<ContactResponse> createContact(Map<String, dynamic> data);
  Future<ContactResponse> updateContact(String id, Map<String, dynamic> data);
  Future<void> deleteContact(String id);
}

class ContactRemoteDataSourceImpl implements ContactRemoteDataSource {
  final ApiClient apiClient;

  ContactRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ContactResponse>> getContacts() async {
    final response = await apiClient.get(ApiEndpoints.contacts);
    final List<dynamic> list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => ContactResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ContactResponse> getContactById(String id) async {
    final response = await apiClient.get('${ApiEndpoints.contacts}/$id');
    return ContactResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<ContactResponse> createContact(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiEndpoints.contacts, data: data);
    return ContactResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<ContactResponse> updateContact(
      String id, Map<String, dynamic> data) async {
    final response =
        await apiClient.put('${ApiEndpoints.contacts}/$id', data: data);
    return ContactResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteContact(String id) async {
    await apiClient.delete('${ApiEndpoints.contacts}/$id');
  }
}
