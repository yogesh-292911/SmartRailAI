import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smart_rail/utils/theme.dart';

class QrPreviewScreen extends StatelessWidget {
  const QrPreviewScreen({super.key, required this.code, required this.title});
  final String code;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(data: code, size: 240),
            const SizedBox(height: 12),
            Text(
              code,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: SmartRailTheme.navy,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Screenshot or print this QR and attach it to the demonstration asset.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
