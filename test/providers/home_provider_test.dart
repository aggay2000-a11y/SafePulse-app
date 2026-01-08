import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safepulse/providers/home_provider.dart';
import 'package:safepulse/providers/permission_provider.dart';
import 'package:safepulse/main.dart';

void main() {
  group('HomeProvider - SMS and Permission Flow', () {
    testWidgets('should initialize correctly', (WidgetTester tester) async {
      final permissionProvider = PermissionProvider();
      final homeProvider = HomeProvider();
      
      final testWidget = MaterialApp(
        navigatorKey: navigatorKey,
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: permissionProvider),
            ChangeNotifierProvider.value(value: homeProvider),
          ],
          child: const Scaffold(),
        ),
      );
      
      await tester.pumpWidget(testWidget);
      
      expect(homeProvider.sending, false);
      expect(homeProvider.activeSos, false);
      expect(homeProvider.checkinActive, false);
    });

    test('should have correct initial state', () {
      final homeProvider = HomeProvider();
      expect(homeProvider.sending, false);
      expect(homeProvider.activeSos, false);
      expect(homeProvider.status, '');
    });

    // Note: Full integration tests require mocking:
    // - PermissionProvider.checkAndRequestPermissions()
    // - SMSService.launchSMS()
    // - Geolocator.getCurrentPosition()
    // - StorageService methods
  });
}

