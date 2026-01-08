import '../services/storage_service.dart';

class SettingsController {
  String? _pin;
  bool _silentMode = false;

  String? get pin => _pin;
  bool get silentMode => _silentMode;
  bool get hasPin => _pin != null && _pin!.isNotEmpty;

  Future<void> loadSettings() async {
    _pin = await StorageService.getPin();
    _silentMode = await StorageService.getSilentMode();
  }

  Future<void> setPin(String pin) async {
    await StorageService.setPin(pin);
    _pin = pin;
  }

  Future<void> setSilentMode(bool value) async {
    await StorageService.setSilentMode(value);
    _silentMode = value;
  }
}

