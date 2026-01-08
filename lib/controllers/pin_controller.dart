import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class PinController {
  static Future<bool> verifyPin(BuildContext context) async {
    final saved = await StorageService.getPin();
    if (saved == null || saved.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No PIN set. Please set a PIN in Settings.')),
      );
      return false;
    }
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enter PIN'),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, controller.text == saved);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (ok != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wrong PIN')),
      );
      return false;
    }
    return true;
  }
}

