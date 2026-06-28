import '../../domain/entities/contact_entity.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/contact_remote_datasource.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactRemoteDataSource remoteDataSource;

  ContactRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ContactEntity>> getContacts() async {
    final responses = await remoteDataSource.getContacts();
    return responses.map((e) => e.toEntity()).toList();
  }

  @override
  Future<ContactEntity> getContactById(String id) async {
    final response = await remoteDataSource.getContactById(id);
    return response.toEntity();
  }

  @override
  Future<ContactEntity> createContact(Map<String, dynamic> data) async {
    final response = await remoteDataSource.createContact(data);
    return response.toEntity();
  }

  @override
  Future<ContactEntity> updateContact(String id, Map<String, dynamic> data) async {
    final response = await remoteDataSource.updateContact(id, data);
    return response.toEntity();
  }

  @override
  Future<void> deleteContact(String id) async {
    await remoteDataSource.deleteContact(id);
  }
}
