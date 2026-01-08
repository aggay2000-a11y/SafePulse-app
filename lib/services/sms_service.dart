import 'package:url_launcher/url_launcher.dart';
import '../models/contact.dart';

class SMSService {
  /// Check if SMS can be launched
  Future<bool> canSendSMS() async {
    // Try smsto: first (more reliable on Android)
    final smstoUri = Uri.parse("smsto:?body=test");
    if (await canLaunchUrl(smstoUri)) return true;
    
    // Fallback to sms:
    final smsUri = Uri.parse("sms:?body=test");
    return await canLaunchUrl(smsUri);
  }

  /// Launch SMS app with message
  Future<bool> launchSMS({
    required String message,
    List<Contact>? contacts,
  }) async {
    final encoded = Uri.encodeComponent(message);
    bool launched = false;
    
    // Try smsto: first (more reliable on Android)
    Uri smsUri = Uri.parse("smsto:?body=$encoded");
    if (await canLaunchUrl(smsUri)) {
      try {
        await launchUrl(
          smsUri,
          mode: LaunchMode.externalApplication,
        );
        launched = true;
      } catch (e) {
        // Try fallback
      }
    }
    
    // Fallback to sms: if smsto: didn't work
    if (!launched) {
      smsUri = Uri.parse("sms:?body=$encoded");
      if (await canLaunchUrl(smsUri)) {
        try {
          await launchUrl(
            smsUri,
            mode: LaunchMode.externalApplication,
          );
          launched = true;
        } catch (e) {
          return false;
        }
      }
    }
    
    // Last fallback: try with empty phone number
    if (!launched) {
      smsUri = Uri.parse("smsto::?body=$encoded");
      if (await canLaunchUrl(smsUri)) {
        try {
          await launchUrl(
            smsUri,
            mode: LaunchMode.externalApplication,
          );
          launched = true;
        } catch (e) {
          return false;
        }
      }
    }
    
    return launched;
  }

  /// Prepare SMS message body
  String prepareSMSMessage({
    required bool fromCheckin,
    required DateTime time,
    required String? locationUrl,
    required List<Contact> contacts,
    String? note,
  }) {
    final nowStr = time.toString().substring(0, 16);
    final battery = "n/a";

    String contactsText = contacts.isEmpty
        ? "No contacts set."
        : contacts.map((c) => c.phone).join(', ');

    String baseText = fromCheckin
        ? "SOS! Missed check-in. I may need help."
        : "SOS! I need help.";

    String body = "$baseText\n"
        "Time: $nowStr\n"
        "Battery: $battery\n";

    if (note != null && note.trim().isNotEmpty) {
      body += "Note: $note\n";
    }
    if (locationUrl != null && locationUrl.isNotEmpty) {
      body += "Location: $locationUrl\n";
    } else {
      body += "Location unavailable.\n";
    }

    body += "Contacts listed in app: $contactsText";

    return body;
  }
}

