import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../models/sos_event.dart';
import '../services/storage_service.dart';
import '../services/sms_service.dart';
import 'pin_controller.dart';

class HomeController {
  final _uuid = const Uuid();
  final _smsService = SMSService();
  Timer? _checkinTimer;
  
  bool sending = false;
  String status = "";
  bool activeSos = false;
  SosEvent? currentSos;
  bool checkinActive = false;
  DateTime? checkinEnd;
  String? checkinNote;

  void dispose() {
    _checkinTimer?.cancel();
  }

  Future<void> loadCheckInState() async {
    final checkIn = await StorageService.loadCheckIn();
    checkinActive = checkIn.active;
    checkinEnd = checkIn.endTime;
    checkinNote = checkIn.note;
  }

  void startCheckInWatcher(Function() onCheckInExpired) {
    _checkinTimer?.cancel();
    _checkinTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!checkinActive || checkinEnd == null) return;
      if (DateTime.now().isAfter(checkinEnd!)) {
        checkinActive = false;
        await StorageService.saveCheckIn(active: false);
        if (!activeSos) {
          onCheckInExpired();
        }
      }
    });
  }

  Future<void> triggerSOS({
    required Function() onStateChanged,
    bool fromCheckin = false,
    String? note,
  }) async {
    sending = true;
    status = "Getting your location…";
    onStateChanged();

    // Get location (permissions already checked by provider)
    double? lat;
    double? lon;
    String mapsUrl = "";
    
    try {
      final pos = await Geolocator.getCurrentPosition();
      lat = pos.latitude;
      lon = pos.longitude;
      mapsUrl = "https://maps.google.com/?q=$lat,$lon";
    } catch (e) {
      status = "Location error (will send without map): $e";
    }

    final now = DateTime.now();
    final contacts = await StorageService.loadContacts();

    // Prepare SMS message using SMSService
    final message = _smsService.prepareSMSMessage(
      fromCheckin: fromCheckin,
      time: now,
      locationUrl: mapsUrl.isNotEmpty ? mapsUrl : null,
      contacts: contacts,
      note: note,
    );

    // Launch SMS app
    try {
      final launched = await _smsService.launchSMS(message: message);
      
      if (launched) {
        status = "SOS prepared in SMS app";
        activeSos = true;
        currentSos = SosEvent(
          id: _uuid.v4(),
          time: now,
          type: fromCheckin ? 'checkin' : 'manual',
          status: 'sent',
          lat: lat,
          lon: lon,
          note: note,
        );
        await _addHistoryEvent(currentSos!);
      } else {
        status = "Could not open SMS app. Please check if SMS app is installed.";
        final failEvent = SosEvent(
          id: _uuid.v4(),
          time: now,
          type: fromCheckin ? 'checkin' : 'manual',
          status: 'failed',
          lat: lat,
          lon: lon,
          note: note,
        );
        await _addHistoryEvent(failEvent);
      }
    } catch (e) {
      status = "Error: $e";
      final failEvent = SosEvent(
        id: _uuid.v4(),
        time: now,
        type: fromCheckin ? 'checkin' : 'manual',
        status: 'failed',
        lat: lat,
        lon: lon,
        note: note,
      );
      await _addHistoryEvent(failEvent);
    }

    sending = false;
    onStateChanged();
  }

  Future<void> _addHistoryEvent(SosEvent event) async {
    final history = await StorageService.loadHistory();
    history.insert(0, event);
    await StorageService.saveHistory(history);
  }

  Future<bool> cancelSos(BuildContext context) async {
    if (!activeSos) return false;
    final ok = await PinController.verifyPin(context);
    if (!ok) return false;

    activeSos = false;
    status = "SOS ended.";

    if (currentSos != null) {
      final updated = SosEvent(
        id: currentSos!.id,
        time: currentSos!.time,
        type: currentSos!.type,
        status: 'cancelled',
        lat: currentSos!.lat,
        lon: currentSos!.lon,
        note: currentSos!.note,
      );
      final history = await StorageService.loadHistory();
      final index = history.indexWhere((e) => e.id == currentSos!.id);
      if (index != -1) {
        history[index] = updated;
        await StorageService.saveHistory(history);
      }
      currentSos = updated;
    }
    return true;
  }

  Future<bool> cancelCheckIn(BuildContext context) async {
    if (!checkinActive) return false;
    final ok = await PinController.verifyPin(context);
    if (!ok) return false;
    await StorageService.saveCheckIn(active: false);
    checkinActive = false;
    checkinEnd = null;
    checkinNote = null;
    return true;
  }

  String getCheckinRemainingText() {
    if (!checkinActive || checkinEnd == null) return "No active check-in";
    final diff = checkinEnd!.difference(DateTime.now());
    if (diff.isNegative) return "Check-in time passed.";
    final mins = diff.inMinutes;
    final secs = diff.inSeconds % 60;
    return "Check-in: ${mins}m ${secs}s remaining";
  }
}

