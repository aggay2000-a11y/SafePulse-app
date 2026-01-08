import 'package:permission_handler/permission_handler.dart' as ph;

class PermissionController {
  bool _locationDeniedOnce = false;
  bool _smsDeniedOnce = false;
  bool _locationDeniedTwice = false;
  bool _smsDeniedTwice = false;
  bool _isRequestingPermissions = false;

  bool get locationDeniedOnce => _locationDeniedOnce;
  bool get smsDeniedOnce => _smsDeniedOnce;
  bool get locationDeniedTwice => _locationDeniedTwice;
  bool get smsDeniedTwice => _smsDeniedTwice;
  bool get isRequestingPermissions => _isRequestingPermissions;

  /// Request all permissions on first launch
  Future<Map<String, bool>> requestInitialPermissions() async {
    // Prevent concurrent permission requests
    if (_isRequestingPermissions) {
      // Wait a bit and return current status
      await Future.delayed(const Duration(milliseconds: 100));
      return {
        'location': false,
        'sms': false,
      };
    }

    _isRequestingPermissions = true;
    try {
      final results = <String, bool>{};

      // Request permissions simultaneously to avoid sequential request issues
      final permissionResults = await Future.wait([
        ph.Permission.locationWhenInUse.request(),
        ph.Permission.sms.request(),
      ]);

      final locationStatus = permissionResults[0];
      final smsStatus = permissionResults[1];

      results['location'] = locationStatus.isGranted;
      if (locationStatus.isDenied) {
        _locationDeniedOnce = true;
      } else if (locationStatus.isPermanentlyDenied) {
        _locationDeniedOnce = true;
        _locationDeniedTwice = true;
      }

      results['sms'] = smsStatus.isGranted;
      if (smsStatus.isDenied) {
        _smsDeniedOnce = true;
      } else if (smsStatus.isPermanentlyDenied) {
        _smsDeniedOnce = true;
        _smsDeniedTwice = true;
      }

      return results;
    } finally {
      _isRequestingPermissions = false;
    }
  }

  /// Check and request permissions before SOS
  Future<Map<String, dynamic>> checkAndRequestPermissions() async {
    final results = <String, dynamic>{};

    // Check location permission
    final locationStatus = await ph.Permission.locationWhenInUse.status;
    if (!locationStatus.isGranted) {
      if (_locationDeniedTwice || locationStatus.isPermanentlyDenied) {
        results['location'] = 'permanently_denied';
        _locationDeniedTwice = true;
      } else {
        // Request again
        final newStatus = await ph.Permission.locationWhenInUse.request();
        if (newStatus.isGranted) {
          results['location'] = 'granted';
          _locationDeniedOnce = false;
        } else if (newStatus.isDenied) {
          results['location'] = 'denied';
          if (_locationDeniedOnce) {
            _locationDeniedTwice = true;
          } else {
            _locationDeniedOnce = true;
          }
        } else if (newStatus.isPermanentlyDenied) {
          results['location'] = 'permanently_denied';
          _locationDeniedTwice = true;
        }
      }
    } else {
      results['location'] = 'granted';
    }

    // Check SMS permission
    final smsStatus = await ph.Permission.sms.status;
    if (!smsStatus.isGranted) {
      if (_smsDeniedTwice || smsStatus.isPermanentlyDenied) {
        results['sms'] = 'permanently_denied';
        _smsDeniedTwice = true;
      } else {
        // Request again
        final newStatus = await ph.Permission.sms.request();
        if (newStatus.isGranted) {
          results['sms'] = 'granted';
          _smsDeniedOnce = false;
        } else if (newStatus.isDenied) {
          results['sms'] = 'denied';
          if (_smsDeniedOnce) {
            _smsDeniedTwice = true;
          } else {
            _smsDeniedOnce = true;
          }
        } else if (newStatus.isPermanentlyDenied) {
          results['sms'] = 'permanently_denied';
          _smsDeniedTwice = true;
        }
      }
    } else {
      results['sms'] = 'granted';
    }

    return results;
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }

  /// Get permission status messages
  String getPermissionStatusMessage(Map<String, dynamic> permissionResults) {
    final locationStatus = permissionResults['location'];
    final smsStatus = permissionResults['sms'];

    if (locationStatus == 'permanently_denied' || smsStatus == 'permanently_denied') {
      return 'Location or SMS permission denied. Please grant permissions in Settings to use SOS feature.';
    }

    if (locationStatus == 'denied') {
      return 'Location permission required for SOS.';
    }

    if (smsStatus == 'denied') {
      return 'SMS permission required for SOS.';
    }

    if (locationStatus == 'granted' && smsStatus == 'granted') {
      return 'All permissions granted.';
    }

    return 'Checking permissions...';
  }

  /// Check if all required permissions are granted (location and SMS)
  bool areAllPermissionsGranted(Map<String, dynamic> permissionResults) {
    return permissionResults['location'] == 'granted' &&
        permissionResults['sms'] == 'granted';
  }
}

