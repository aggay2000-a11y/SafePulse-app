import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../main.dart';
import 'permission_provider.dart';

class HomeProvider extends ChangeNotifier {
  final HomeController _controller = HomeController();
  Timer? _countdownTimer;

  bool get sending => _controller.sending;
  String get status => _controller.status;
  bool get activeSos => _controller.activeSos;
  bool get checkinActive => _controller.checkinActive;
  String get checkinRemainingText => _controller.getCheckinRemainingText();

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    if (checkinActive) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (checkinActive) {
          notifyListeners();
        } else {
          _countdownTimer?.cancel();
        }
      });
    }
  }

  void _stopCountdownTimer() {
    _countdownTimer?.cancel();
  }

  Future<void> initialize(BuildContext context) async {
    await _controller.loadCheckInState();
    _controller.startCheckInWatcher(() {
      _stopCountdownTimer();
      _triggerSOSFromCheckIn();
    });
    _startCountdownTimer();
    notifyListeners();
  }

  Future<void> _triggerSOSFromCheckIn() async {
    final context = navigatorKey.currentContext;
    if (context == null) {
      // If context is not available (app in background), proceed with SOS anyway
      // This is an emergency situation - we try to send SOS even without UI interactions
      // The controller will handle gracefully (location might fail, SMS might not work)
      await _controller.triggerSOS(
        onStateChanged: () => notifyListeners(),
        fromCheckin: true,
        note: _controller.checkinNote,
      );
      return;
    }
    // Context available - use full permission check with UI feedback
    await triggerSOS(context, fromCheckin: true, note: _controller.checkinNote);
  }

  Future<void> triggerSOS(BuildContext context, {bool fromCheckin = false, String? note}) async {
    final permissionProvider = Provider.of<PermissionProvider>(context, listen: false);
    
    // Check and request permissions
    final permissionResults = await permissionProvider.checkAndRequestPermissions();
    
    // Check if permissions are permanently denied
    final locationStatus = permissionResults['location'];
    final smsStatus = permissionResults['sms'];
    
    if (locationStatus == 'permanently_denied' || smsStatus == 'permanently_denied') {
      // Open settings if denied twice
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
            'SOS requires location and SMS permissions. Please grant these permissions in Settings to use the SOS feature.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      
      if (shouldOpenSettings == true) {
        await permissionProvider.openAppSettings();
      }
      return;
    }
    
    // If permissions not granted, don't proceed
    if (!permissionProvider.areAllPermissionsGranted(permissionResults)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(permissionProvider.getPermissionStatusMessage(permissionResults)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // All permissions granted, proceed with SOS
    await _controller.triggerSOS(
      onStateChanged: () => notifyListeners(),
      fromCheckin: fromCheckin,
      note: note,
    );
  }

  Future<void> cancelSos(BuildContext context) async {
    final changed = await _controller.cancelSos(context);
    if (changed) notifyListeners();
  }

  Future<void> cancelCheckIn(BuildContext context) async {
    final changed = await _controller.cancelCheckIn(context);
    if (changed) {
      _stopCountdownTimer();
      notifyListeners();
    }
  }

  Future<void> refreshCheckIn(BuildContext context) async {
    await _controller.loadCheckInState();
    _controller.startCheckInWatcher(() {
      _stopCountdownTimer();
      _triggerSOSFromCheckIn();
    });
    _startCountdownTimer();
    notifyListeners();
  }
}

