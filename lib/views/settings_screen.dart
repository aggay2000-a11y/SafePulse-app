import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
    });
  }

  Future<void> _setPinDialog() async {
    final provider = context.read<SettingsProvider>();
    // Load existing PIN if available
    await provider.loadSettings();
    final existingPin = provider.pin ?? '';
    
    final p1 = TextEditingController(text: existingPin);
    final p2 = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? pinError;
    String? confirmPinError;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(provider.hasPin ? 'Change PIN' : 'Set PIN'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: p1,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: provider.hasPin ? 'New PIN' : 'PIN',
                    errorText: pinError,
                    helperText: 'Minimum 4 digits',
                  ),
                  onChanged: (_) {
                    setState(() {
                      pinError = null;
                      confirmPinError = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: p2,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Confirm PIN',
                    errorText: confirmPinError,
                  ),
                  onChanged: (_) {
                    setState(() {
                      confirmPinError = null;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Clear previous errors
                setState(() {
                  pinError = null;
                  confirmPinError = null;
                });

                // Validate PIN
                if (p1.text.isEmpty) {
                  setState(() {
                    pinError = 'PIN cannot be empty';
                  });
                  return;
                }

                if (p1.text.length < 4) {
                  setState(() {
                    pinError = 'PIN must be at least 4 digits';
                  });
                  return;
                }

                // Check if PIN is being changed (not same as existing)
                if (provider.hasPin && p1.text == existingPin) {
                  setState(() {
                    pinError = 'Please enter a different PIN';
                  });
                  return;
                }

                // Validate confirmation
                if (p2.text.isEmpty) {
                  setState(() {
                    confirmPinError = 'Please confirm your PIN';
                  });
                  return;
                }

                if (p1.text != p2.text) {
                  setState(() {
                    confirmPinError = 'PINs do not match';
                  });
                  return;
                }

                // All validations passed
                Navigator.pop(context, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      await provider.setPin(p1.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN saved.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            children: [
              ListTile(
                title: Text(provider.hasPin ? 'Change PIN' : 'Set PIN'),
                subtitle: const Text('PIN is required to cancel SOS and check-ins'),
                trailing: const Icon(Icons.keyboard),
                onTap: _setPinDialog,
              ),
              SwitchListTile(
                title: const Text('Silent mode'),
                subtitle: const Text('Disable loud alerts (future use)'),
                value: provider.silentMode,
                onChanged: (value) => provider.setSilentMode(value),
              ),
              const ListTile(
                title: Text('About SafePulse'),
                subtitle: Text('This app helps you alert trusted contacts in emergencies.'),
              ),
            ],
          ),
        );
      },
    );
  }
}

