import '../models/sos_event.dart';
import '../services/storage_service.dart';

class HistoryController {
  List<SosEvent> _events = [];

  List<SosEvent> get events => _events;

  Future<void> loadHistory() async {
    _events = await StorageService.loadHistory();
  }

  Future<void> clearHistory() async {
    await StorageService.saveHistory([]);
    _events = [];
  }
}

