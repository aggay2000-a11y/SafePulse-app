import 'package:flutter_test/flutter_test.dart';
import 'package:safepulse/controllers/home_controller.dart';

void main() {
  group('HomeController - SMS Integration', () {
    late HomeController controller;

    setUp(() {
      controller = HomeController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('should initialize correctly', () {
      expect(controller.sending, false);
      expect(controller.activeSos, false);
      expect(controller.checkinActive, false);
      expect(controller.status, '');
    });

    test('getCheckinRemainingText should return correct format when inactive', () {
      controller.checkinActive = false;
      expect(controller.getCheckinRemainingText(), 'No active check-in');
    });

    test('getCheckinRemainingText should return correct format when active', () {
      controller.checkinActive = true;
      controller.checkinEnd = DateTime.now().add(const Duration(minutes: 30));
      final text = controller.getCheckinRemainingText();
      expect(text, contains('Check-in:'));
      expect(text, contains('remaining'));
    });

    test('getCheckinRemainingText should handle expired check-in', () {
      controller.checkinActive = true;
      controller.checkinEnd = DateTime.now().subtract(const Duration(minutes: 5));
      final text = controller.getCheckinRemainingText();
      expect(text, contains('Check-in time passed.'));
    });

    // Note: Full integration tests for triggerSOS require mocking:
    // - Geolocator.getCurrentPosition()
    // - SMSService.launchSMS()
    // - StorageService.loadContacts()
    // - StorageService.saveHistory()
  });
}

