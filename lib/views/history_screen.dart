import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('SOS History'),
            actions: [
              if (provider.events.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await provider.clearHistory();
                  },
                ),
            ],
          ),
          body: provider.events.isEmpty
              ? const Center(child: Text('No SOS events yet.'))
              : ListView.separated(
                  itemCount: provider.events.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final e = provider.events[i];
                    final dateStr =
                        "${e.time.year}-${e.time.month.toString().padLeft(2, '0')}-${e.time.day.toString().padLeft(2, '0')} "
                        "${e.time.hour.toString().padLeft(2, '0')}:${e.time.minute.toString().padLeft(2, '0')}";
                    return ListTile(
                      title: Text(
                          "${e.type == 'manual' ? 'Manual SOS' : 'Check-in SOS'} (${e.status})"),
                      subtitle: Text("$dateStr\n${e.note ?? ''}"),
                      isThreeLine: true,
                    );
                  },
                ),
        );
      },
    );
  }
}

