import 'package:uuid/uuid.dart';
import '../models/contact.dart';
import '../services/storage_service.dart';

class ContactsController {
  final _uuid = const Uuid();
  List<Contact> _contacts = [];

  List<Contact> get contacts => _contacts;

  Future<void> loadContacts() async {
    _contacts = await StorageService.loadContacts();
  }

  Future<void> saveContacts() async {
    await StorageService.saveContacts(_contacts);
  }

  Future<void> addContact(String name, String phone) async {
    _contacts.add(Contact(
      id: _uuid.v4(),
      name: name.trim(),
      phone: phone.trim(),
    ));
    await saveContacts();
  }

  Future<void> updateContact(int index, String name, String phone) async {
    final existing = _contacts[index];
    _contacts[index] = Contact(
      id: existing.id,
      name: name.trim(),
      phone: phone.trim(),
    );
    await saveContacts();
  }

  Future<void> deleteContact(int index) async {
    _contacts.removeAt(index);
    await saveContacts();
  }
}

