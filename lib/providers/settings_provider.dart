import 'package:flutter/material.dart';
import '../controllers/settings_controller.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsController _controller = SettingsController();

  String? get pin => _controller.pin;
  bool get silentMode => _controller.silentMode;
  bool get hasPin => _controller.hasPin;

  Future<void> loadSettings() async {
    await _controller.loadSettings();
    notifyListeners();
  }

  Future<void> setPin(String pin) async {
    await _controller.setPin(pin);
    notifyListeners();
  }

  Future<void> setSilentMode(bool value) async {
    await _controller.setSilentMode(value);
    notifyListeners();
  }
}

