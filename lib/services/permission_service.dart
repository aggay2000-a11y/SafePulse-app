import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request location and SMS permissions
  static Future<void> requestPermissions() async {
    await Permission.locationWhenInUse.request();
    await Permission.sms.request();
  }

  /// Check if location permission is granted
  static Future<bool> isLocationGranted() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  /// Check if SMS permission is granted
  static Future<bool> isSmsGranted() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }

  /// Check if all required permissions are granted
  static Future<bool> areAllPermissionsGranted() async {
    final location = await isLocationGranted();
    final sms = await isSmsGranted();
    return location && sms;
  }
}

