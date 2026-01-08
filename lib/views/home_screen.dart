import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import 'check_in_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HomeProvider>().initialize(context);
      }
    });
  }

  Future<void> _navigateToCheckIn() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckInScreen()),
    );
    if (mounted) {
      context.read<HomeProvider>().refreshCheckIn(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        return SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'You are safe',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.checkinRemainingText,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onLongPress: provider.sending
                        ? null
                        : () => provider.triggerSOS(context),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: provider.sending ? Colors.grey : Colors.red,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 16,
                            spreadRadius: 4,
                            offset: const Offset(0, 8),
                            color: Colors.black.withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        provider.sending
                            ? 'Sending…'
                            : provider.activeSos
                                ? 'SOS\nACTIVE'
                                : 'HOLD\nSOS',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.status,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _navigateToCheckIn,
                        icon: const Icon(Icons.timer),
                        label: const Text('Check-in'),
                      ),
                      const SizedBox(width: 16),
                      if (provider.checkinActive)
                        ElevatedButton.icon(
                          onPressed: () => provider.cancelCheckIn(context),
                          icon: const Icon(Icons.check),
                          label: const Text('I\'m safe'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (provider.activeSos)
                    ElevatedButton.icon(
                      onPressed: () => provider.cancelSos(context),
                      icon: const Icon(Icons.stop),
                      label: const Text('End SOS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

