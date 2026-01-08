import 'package:flutter/material.dart';
import '../controllers/permission_controller.dart';

class PermissionProvider extends ChangeNotifier {
  final PermissionController _controller = PermissionController();

  bool get locationDeniedOnce => _controller.locationDeniedOnce;
  bool get smsDeniedOnce => _controller.smsDeniedOnce;
  bool get locationDeniedTwice => _controller.locationDeniedTwice;
  bool get smsDeniedTwice => _controller.smsDeniedTwice;

  String _statusMessage = '';
  bool _isRequestingPermissions = false;

  String get statusMessage => _statusMessage;
  bool get isRequestingPermissions => _isRequestingPermissions;

  /// Request permissions on first app launch
  Future<Map<String, bool>> requestInitialPermissions() async {
    // Prevent concurrent calls
    if (_isRequestingPermissions) {
      return {
        'location': false,
        'sms': false,
      };
    }

    _isRequestingPermissions = true;
    _statusMessage = 'Requesting permissions...';
    notifyListeners();

    try {
      final results = await _controller.requestInitialPermissions();

      _statusMessage = _controller.getPermissionStatusMessage(
        results.map((key, value) => MapEntry(key, value ? 'granted' : 'denied')),
      );
      notifyListeners();

      return results;
    } finally {
      _isRequestingPermissions = false;
      notifyListeners();
    }
  }

  /// Check and request permissions before SOS
  Future<Map<String, dynamic>> checkAndRequestPermissions() async {
    // Prevent concurrent calls
    if (_isRequestingPermissions) {
      // Return current status if already requesting
      await Future.delayed(const Duration(milliseconds: 100));
      return {
        'location': 'denied',
        'sms': 'denied',
      };
    }

    _isRequestingPermissions = true;
    _statusMessage = 'Checking permissions...';
    notifyListeners();

    try {
      final results = await _controller.checkAndRequestPermissions();

      _statusMessage = _controller.getPermissionStatusMessage(results);
      notifyListeners();

      return results;
    } finally {
      _isRequestingPermissions = false;
      notifyListeners();
    }
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await _controller.openAppSettings();
  }

  /// Check if all permissions are granted
  bool areAllPermissionsGranted(Map<String, dynamic> permissionResults) {
    return _controller.areAllPermissionsGranted(permissionResults);
  }

  /// Get permission status message
  String getPermissionStatusMessage(Map<String, dynamic> permissionResults) {
    return _controller.getPermissionStatusMessage(permissionResults);
  }

  void clearStatusMessage() {
    _statusMessage = '';
    notifyListeners();
  }
}

