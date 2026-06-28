import '../entities/contact_entity.dart';

abstract class ContactRepository {
  Future<List<ContactEntity>> getContacts();
  Future<ContactEntity> getContactById(String id);
  Future<ContactEntity> createContact(Map<String, dynamic> data);
  Future<ContactEntity> updateContact(String id, Map<String, dynamic> data);
  Future<void> deleteContact(String id);
}
