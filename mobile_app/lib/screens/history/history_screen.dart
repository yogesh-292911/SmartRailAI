import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_rail/services/session.dart';
import 'package:smart_rail/utils/theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.assetId, required this.assetCode});
  final int assetId;
  final String assetCode;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> events = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await context.read<SessionController>().api.get(
          '/api/assets/${widget.assetId}/history',
        );
    setState(() {
      events = List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.assetCode} history')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final event = events[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: SmartRailTheme.navy.withValues(alpha: 0.1),
                    child: Text(
                      (event['date']?.toString() ?? '').split('-').first,
                      style: const TextStyle(fontSize: 11, color: SmartRailTheme.navy),
                    ),
                  ),
                  title: Text(event['title']?.toString() ?? ''),
                  subtitle: Text('${event['date']}\n${event['detail']}'),
                  isThreeLine: true,
                );
              },
            ),
    );
  }
}
