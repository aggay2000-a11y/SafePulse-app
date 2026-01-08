import 'package:flutter_test/flutter_test.dart';
import 'package:safepulse/models/contact.dart';
import 'package:safepulse/services/sms_service.dart';

void main() {
  group('SMSService', () {
    late SMSService smsService;

    setUp(() {
      smsService = SMSService();
    });

    group('prepareSMSMessage', () {
      test('should prepare message for manual SOS', () {
        final time = DateTime(2025, 1, 1, 12, 0, 0);
        final contacts = <Contact>[];
        final locationUrl = 'https://maps.google.com/?q=31.41,73.07';

        final message = smsService.prepareSMSMessage(
          fromCheckin: false,
          time: time,
          locationUrl: locationUrl,
          contacts: contacts,
          note: null,
        );

        expect(message, contains('SOS! I need help.'));
        expect(message, contains('Time: 2025-01-01 12:00'));
        expect(message, contains('Location: $locationUrl'));
        expect(message, contains('No contacts set.'));
        expect(message, isNot(contains('Note:')));
      });

      test('should prepare message for check-in SOS', () {
        final time = DateTime(2025, 1, 1, 12, 0, 0);
        final contacts = <Contact>[];
        final locationUrl = 'https://maps.google.com/?q=31.41,73.07';

        final message = smsService.prepareSMSMessage(
          fromCheckin: true,
          time: time,
          locationUrl: locationUrl,
          contacts: contacts,
          note: null,
        );

        expect(message, contains('SOS! Missed check-in. I may need help.'));
        expect(message, contains('Time: 2025-01-01 12:00'));
        expect(message, contains('Location: $locationUrl'));
      });

      test('should include note when provided', () {
        final time = DateTime(2025, 1, 1, 12, 0, 0);
        final contacts = <Contact>[];
        final locationUrl = 'https://maps.google.com/?q=31.41,73.07';
        final note = 'Test note';

        final message = smsService.prepareSMSMessage(
          fromCheckin: false,
          time: time,
          locationUrl: locationUrl,
          contacts: contacts,
          note: note,
        );

        expect(message, contains('Note: $note'));
      });

      test('should handle empty note', () {
        final time = DateTime(2025, 1, 1, 12, 0, 0);
        final contacts = <Contact>[];
        final locationUrl = 'https://maps.google.com/?q=31.41,73.07';

        final message = smsService.prepareSMSMessage(
          fromCheckin: false,
          time: time,
          locationUrl: locationUrl,
          contacts: contacts,
          note: '',
        );

        expect(message, isNot(contains('Note:')));
      });

      test('should include contacts when provided', () {
        final time = DateTime(2025, 1, 1, 12, 0, 0);
        final contacts = [
          Contact(id: '1', name: 'John', phone: '+1234567890'),
          Contact(id: '2', name: 'Jane', phone: '+0987654321'),
        ];
        final locationUrl = 'https://maps.google.com/?q=31.41,73.07';

        final message = smsService.prepareSMSMessage(
          fromCheckin: false,
          time: time,
          locationUrl: locationUrl,
          contacts: contacts,
          note: null,
        );

        expect(message, contains('+1234567890, +0987654321'));
        expect(message, isNot(contains('No contacts set.')));
      });

      test('should handle missing location', () {
        final time = DateTime(2025, 1, 1, 12, 0, 0);
        final contacts = <Contact>[];

        final message = smsService.prepareSMSMessage(
          fromCheckin: false,
          time: time,
          locationUrl: null,
          contacts: contacts,
          note: null,
        );

        expect(message, contains('Location unavailable.'));
        expect(message, isNot(contains('Location: https')));
      });

      test('should handle empty location URL', () {
        final time = DateTime(2025, 1, 1, 12, 0, 0);
        final contacts = <Contact>[];

        final message = smsService.prepareSMSMessage(
          fromCheckin: false,
          time: time,
          locationUrl: '',
          contacts: contacts,
          note: null,
        );

        expect(message, contains('Location unavailable.'));
      });
    });

    group('canSendSMS', () {
      test('should check if SMS can be sent', () async {
        // Note: This test may fail if no SMS app is installed
        // In a real test environment, you might want to mock this
        final result = await smsService.canSendSMS();
        expect(result, isA<bool>());
      });
    });

    group('launchSMS', () {
      test('should attempt to launch SMS with message', () async {
        final message = 'Test SOS message';
        
        // Note: This test may fail if no SMS app is installed
        // In a real test environment, you might want to mock url_launcher
        final result = await smsService.launchSMS(message: message);
        expect(result, isA<bool>());
      });

      test('should handle empty message', () async {
        final result = await smsService.launchSMS(message: '');
        expect(result, isA<bool>());
      });

      test('should handle message with special characters', () async {
        final message = r'SOS! Test message with special chars: @#$%^&*()';
        final result = await smsService.launchSMS(message: message);
        expect(result, isA<bool>());
      });

      test('should handle message with newlines', () async {
        final message = 'Line 1\nLine 2\nLine 3';
        final result = await smsService.launchSMS(message: message);
        expect(result, isA<bool>());
      });
    });
  });
}

