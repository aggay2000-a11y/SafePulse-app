import 'package:flutter/material.dart';
import '../controllers/history_controller.dart';
import '../models/sos_event.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryController _controller = HistoryController();

  List<SosEvent> get events => _controller.events;

  Future<void> loadHistory() async {
    await _controller.loadHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _controller.clearHistory();
    notifyListeners();
  }
}

