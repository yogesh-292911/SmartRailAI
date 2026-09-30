import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_rail/services/api_service.dart';
import 'package:smart_rail/services/session.dart';

class AssetFormScreen extends StatefulWidget {
  const AssetFormScreen({super.key});

  @override
  State<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends State<AssetFormScreen> {
  final code = TextEditingController();
  final location = TextEditingController();
  final zone = TextEditingController(text: 'Southern Railway');
  final section = TextEditingController();
  final manufacturer = TextEditingController();
  final life = TextEditingController(text: '20');
  final description = TextEditingController();
  String type = 'Rail Fastener / Clip';
  DateTime installed = DateTime(2022, 3, 12);
  bool loading = false;

  final types = const [
    'Rail Fastener / Clip',
    'Fish Plate',
    'Rail Bolt',
    'Sleeper',
    'Track Joint',
    'Switch/Point Component',
  ];

  Future<void> _save() async {
    setState(() => loading = true);
    try {
      await context.read<SessionController>().api.post('/api/assets', {
        'asset_code': code.text.trim(),
        'asset_type': type,
        'railway_zone': zone.text.trim(),
        'section': section.text.trim(),
        'location': location.text.trim(),
        'manufacturer': manufacturer.text.trim(),
        'installation_date': installed.toIso8601String().split('T').first,
        'expected_life': int.tryParse(life.text) ?? 20,
        'description': description.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    code.dispose();
    location.dispose();
    zone.dispose();
    section.dispose();
    manufacturer.dispose();
    life.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add asset')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: code, decoration: const InputDecoration(labelText: 'Asset code')),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: type,
            items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (value) => setState(() => type = value!),
            decoration: const InputDecoration(labelText: 'Asset type'),
          ),
          const SizedBox(height: 8),
          TextField(controller: location, decoration: const InputDecoration(labelText: 'Location')),
          const SizedBox(height: 8),
          TextField(controller: zone, decoration: const InputDecoration(labelText: 'Railway zone')),
          const SizedBox(height: 8),
          TextField(controller: section, decoration: const InputDecoration(labelText: 'Section')),
          const SizedBox(height: 8),
          TextField(controller: manufacturer, decoration: const InputDecoration(labelText: 'Manufacturer')),
          const SizedBox(height: 8),
          TextField(controller: life, decoration: const InputDecoration(labelText: 'Expected life (years)')),
          const SizedBox(height: 8),
          TextField(controller: description, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: loading ? null : _save,
            child: Text(loading ? 'Saving...' : 'SAVE AND GENERATE QR'),
          ),
        ],
      ),
    );
  }
}
