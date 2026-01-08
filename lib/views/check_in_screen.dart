import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  int minutes = 30;
  final noteController = TextEditingController();

  Future<void> _startCheckIn() async {
    final end = DateTime.now().add(Duration(minutes: minutes));
    await StorageService.saveCheckIn(
      active: true,
      endTime: end,
      note: noteController.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-in started.')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start Check-in')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<int>(
              value: minutes,
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 minutes')),
                DropdownMenuItem(value: 15, child: Text('15 minutes')),
                DropdownMenuItem(value: 30, child: Text('30 minutes')),
                DropdownMenuItem(value: 45, child: Text('45 minutes')),
                DropdownMenuItem(value: 60, child: Text('60 minutes')),
                DropdownMenuItem(value: 90, child: Text('90 minutes')),
                DropdownMenuItem(value: 120, child: Text('120 minutes')),
              ],
              onChanged: (v) => setState(() => minutes = v ?? 30),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _startCheckIn,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}

