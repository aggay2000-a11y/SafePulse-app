import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'contacts_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../providers/permission_provider.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;
  bool _hasRequestedInitialPermissions = false;
  bool _isRequestingPermissions = false;

  final _screens = const [
    HomeScreen(),
    ContactsScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Request permissions on first launch (only once)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasRequestedInitialPermissions && !_isRequestingPermissions && mounted) {
        _hasRequestedInitialPermissions = true;
        _isRequestingPermissions = true;
        context.read<PermissionProvider>().requestInitialPermissions().then((_) {
          if (mounted) {
            _isRequestingPermissions = false;
          }
        }).catchError((e) {
          if (mounted) {
            _isRequestingPermissions = false;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.shield), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.group), label: 'Contacts'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

