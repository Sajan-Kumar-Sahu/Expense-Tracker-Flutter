import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/dependency_injection/injection.dart';
import '../../domain/entities/contact_entity.dart';
import '../../domain/repositories/contact_repository.dart';

class ContactsProvider extends ChangeNotifier {
  final ContactRepository repository;

  ContactsProvider(this.repository) {
    loadContacts();
  }

  bool isLoading = false;
  List<ContactEntity> contacts = [];
  ContactEntity? selectedContact;

  Future<void> loadContacts() async {
    try {
      isLoading = true;
      notifyListeners();
      contacts = await repository.getContacts();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createContact(Map<String, dynamic> data) async {
    try {
      isLoading = true;
      notifyListeners();
      final contact = await repository.createContact(data);
      contacts.insert(0, contact);
      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateContact(String id, Map<String, dynamic> data) async {
    try {
      isLoading = true;
      notifyListeners();
      final updated = await repository.updateContact(id, data);
      final index = contacts.indexWhere((c) => c.id == id);
      if (index != -1) contacts[index] = updated;
      if (selectedContact?.id == id) selectedContact = updated;
      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteContact(String id) async {
    try {
      isLoading = true;
      notifyListeners();
      await repository.deleteContact(id);
      contacts.removeWhere((c) => c.id == id);
      if (selectedContact?.id == id) selectedContact = null;
      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    contacts = [];
    selectedContact = null;
    isLoading = false;
    notifyListeners();
  }
}

final contactsProvider =
    ChangeNotifierProvider<ContactsProvider>((ref) {
  return ContactsProvider(locator<ContactRepository>());
});
