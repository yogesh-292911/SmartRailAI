import 'package:flutter/material.dart';
import 'package:smart_rail/screens/maintenance/maintenance_list_screen.dart';
import 'package:smart_rail/utils/theme.dart';

class AiPredictionScreen extends StatelessWidget {
  const AiPredictionScreen({
    super.key,
    required this.assetCode,
    required this.summary,
    this.extra,
  });

  final String assetCode;
  final Map<String, dynamic> summary;
  final Map<String, dynamic>? extra;

  @override
  Widget build(BuildContext context) {
    final level = (summary['risk_level'] ?? extra?['prediction']?['risk_level'] ?? '').toString();
    final score = summary['risk_score'] ?? extra?['prediction']?['risk_score'] ?? 0;
    final prediction = summary['prediction']?.toString() ?? 'Maintenance risk prediction';
    final recommendation =
        summary['recommendation']?.toString() ?? 'Review this asset during the next inspection cycle.';
    final factors = List<Map<String, dynamic>>.from(
      ((summary['contributing_factors'] ?? extra?['prediction']?['contributing_factors'] ?? []) as List)
          .map((e) => Map<String, dynamic>.from(e as Map)),
    );
    final alert = extra?['alert'] == true || level == 'HIGH';

    return Scaffold(
      appBar: AppBar(title: const Text('AI Predictive Analysis')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(assetCode, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: riskColor(level).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  '$score%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: riskColor(level),
                  ),
                ),
                Text(
                  '$level RISK',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: riskColor(level),
                  ),
                ),
                const SizedBox(height: 8),
                Text(prediction, textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Contributing Factors', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...factors.map((factor) {
            final pct = (factor['percent'] as num?)?.toDouble() ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(factor['name']?.toString() ?? '')),
                      Text('${factor['percent']}%'),
                    ],
                  ),
                  LinearProgressIndicator(
                    value: (pct / 100).clamp(0, 1),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                    color: SmartRailTheme.navy,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Text('Recommendation: $recommendation'),
          const SizedBox(height: 8),
          const Text(
            'Prototype maintenance-risk prediction. Not an official railway safety rating. Trained on synthetic data.',
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
          if (alert) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SmartRailTheme.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SmartRailTheme.danger),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MAINTENANCE ALERT',
                    style: TextStyle(
                      color: SmartRailTheme.danger,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text('Asset: $assetCode'),
                  Text('Risk: $score% $level'),
                  const Text('Priority: HIGH'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MaintenanceListScreen()),
                    ),
                    child: const Text('VIEW MAINTENANCE REQUEST'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
