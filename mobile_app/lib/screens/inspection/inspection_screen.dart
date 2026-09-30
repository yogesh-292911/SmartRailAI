import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_rail/screens/ai_prediction/ai_prediction_screen.dart';
import 'package:smart_rail/services/api_service.dart';
import 'package:smart_rail/services/session.dart';
import 'package:smart_rail/utils/theme.dart';

class InspectionScreen extends StatefulWidget {
  const InspectionScreen({super.key, required this.asset});
  final Map<String, dynamic> asset;

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  String condition = 'Good';
  String damage = 'None';
  String severity = 'Low';
  final remarks = TextEditingController();
  File? photo;
  bool loading = false;

  final conditions = const ['Good', 'Moderate', 'Poor'];
  final damages = const [
    'None',
    'Crack',
    'Wear',
    'Corrosion',
    'Deformation',
    'Loose Component',
    'Other',
  ];
  final severities = const ['Low', 'Medium', 'High'];

  Future<void> _pick(ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source, imageQuality: 75);
    if (file != null) setState(() => photo = File(file.path));
  }

  Future<void> _submit() async {
    setState(() => loading = true);
    try {
      final result = await context.read<SessionController>().api.postMultipart(
            path: '/api/inspections',
            fields: {
              'asset_id': '${widget.asset['id']}',
              'condition': condition,
              'damage_type': damage,
              'severity': severity,
              'remarks': remarks.text,
            },
            file: photo,
          );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AiPredictionScreen(
            assetCode: widget.asset['asset_code'].toString(),
            summary: Map<String, dynamic>.from(result['prediction'] as Map),
            extra: Map<String, dynamic>.from(result as Map),
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    remarks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inspection')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.asset['asset_code'].toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: SmartRailTheme.navy,
            ),
          ),
          Text(widget.asset['asset_type']?.toString() ?? ''),
          const SizedBox(height: 16),
          const Text('Condition', style: TextStyle(fontWeight: FontWeight.w700)),
          Wrap(
            spacing: 8,
            children: conditions
                .map(
                  (item) => ChoiceChip(
                    label: Text(item),
                    selected: condition == item,
                    onSelected: (_) => setState(() => condition = item),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text('Damage', style: TextStyle(fontWeight: FontWeight.w700)),
          Wrap(
            spacing: 8,
            children: damages
                .map(
                  (item) => ChoiceChip(
                    label: Text(item),
                    selected: damage == item,
                    onSelected: (_) => setState(() => damage = item),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text('Severity', style: TextStyle(fontWeight: FontWeight.w700)),
          Wrap(
            spacing: 8,
            children: severities
                .map(
                  (item) => ChoiceChip(
                    label: Text(item),
                    selected: severity == item,
                    onSelected: (_) => setState(() => severity = item),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: remarks,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Remarks'),
          ),
          const SizedBox(height: 12),
          if (photo != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(photo!, height: 160, fit: BoxFit.cover),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('TAKE PHOTO'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('GALLERY'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: loading ? null : _submit,
            child: Text(loading ? 'Submitting...' : 'SUBMIT INSPECTION'),
          ),
        ],
      ),
    );
  }
}
