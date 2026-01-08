import 'package:flutter/material.dart';
import '../controllers/contacts_controller.dart';
import '../models/contact.dart';

class ContactsProvider extends ChangeNotifier {
  final ContactsController _controller = ContactsController();

  List<Contact> get contacts => _controller.contacts;

  Future<void> loadContacts() async {
    await _controller.loadContacts();
    notifyListeners();
  }

  Future<void> addContact(String name, String phone) async {
    await _controller.addContact(name, phone);
    notifyListeners();
  }

  Future<void> updateContact(int index, String name, String phone) async {
    await _controller.updateContact(index, name, phone);
    notifyListeners();
  }

  Future<void> deleteContact(int index) async {
    await _controller.deleteContact(index);
    notifyListeners();
  }
}

