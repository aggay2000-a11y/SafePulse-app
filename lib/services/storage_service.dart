import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sos_event.dart';
import '../models/contact.dart';
import '../models/check_in.dart';

class StorageService {
  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // Contacts
  static Future<List<Contact>> loadContacts() async {
    final prefs = await _prefs;
    final data = prefs.getString('contacts');
    if (data == null) return [];
    final decoded = jsonDecode(data) as List;
    return decoded
        .map((e) => Contact.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveContacts(List<Contact> contacts) async {
    final prefs = await _prefs;
    final jsonList = contacts.map((c) => c.toJson()).toList();
    await prefs.setString('contacts', jsonEncode(jsonList));
  }

  // History
  static Future<List<SosEvent>> loadHistory() async {
    final prefs = await _prefs;
    final data = prefs.getString('history');
    if (data == null) return [];
    final list = List<Map<String, dynamic>>.from(jsonDecode(data));
    return list.map((e) => SosEvent.fromJson(e)).toList();
  }

  static Future<void> saveHistory(List<SosEvent> events) async {
    final prefs = await _prefs;
    await prefs.setString(
      'history',
      jsonEncode(events.map((e) => e.toJson()).toList()),
    );
  }

  // PIN
  static Future<String?> getPin() async {
    final prefs = await _prefs;
    return prefs.getString('pin');
  }

  static Future<void> setPin(String pin) async {
    final prefs = await _prefs;
    await prefs.setString('pin', pin);
  }

  // Silent Mode
  static Future<bool> getSilentMode() async {
    final prefs = await _prefs;
    return prefs.getBool('silentMode') ?? false;
  }

  static Future<void> setSilentMode(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool('silentMode', value);
  }

  // Check-in
  static Future<void> saveCheckIn({
    required bool active,
    DateTime? endTime,
    String? note,
  }) async {
    final prefs = await _prefs;
    await prefs.setBool('checkinActive', active);
    if (!active) {
      await prefs.remove('checkinEnd');
      await prefs.remove('checkinNote');
    } else {
      await prefs.setString('checkinEnd', endTime!.toIso8601String());
      await prefs.setString('checkinNote', note ?? '');
    }
  }

  static Future<CheckIn> loadCheckIn() async {
    final prefs = await _prefs;
    final active = prefs.getBool('checkinActive') ?? false;
    if (!active) {
      return CheckIn(active: false);
    }
    final endStr = prefs.getString('checkinEnd');
    final note = prefs.getString('checkinNote') ?? '';
    if (endStr == null) {
      return CheckIn(active: false);
    }
    return CheckIn(
      active: true,
      endTime: DateTime.parse(endStr),
      note: note.isEmpty ? null : note,
    );
  }
}

