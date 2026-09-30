import 'package:flutter/material.dart';
import 'package:smart_rail/screens/assets/asset_detail_screen.dart';
import 'package:smart_rail/utils/theme.dart';

class MaintenanceAlertsScreen extends StatefulWidget {
  const MaintenanceAlertsScreen({super.key});

  @override
  State<MaintenanceAlertsScreen> createState() => _MaintenanceAlertsScreenState();
}

class _MaintenanceAlertsScreenState extends State<MaintenanceAlertsScreen> {
  String selectedFilter = 'ALL'; // ALL, CRITICAL, WARNING, INFO
  String searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _alerts = [
    {
      'id': 'ALT-102',
      'asset_code': 'IR-TRACK-102',
      'corridor': 'Chennai - Central -> New Delhi',
      'location': 'KM 142/4 (Grand Trunk Corridor)',
      'defect': 'Loose Fastener & Clip Fatigue',
      'severity': 'Critical',
      'type': 'CRITICAL',
      'detected': '2026-09-28 10:32',
      'sensor': 'ITMS Laser Camera + WILD Impact',
      'impact': 'Speed restriction to 45 km/h recommended',
      'status': 'Unresolved',
    },
    {
      'id': 'ALT-048',
      'asset_code': 'SR-TRK-0048',
      'corridor': 'Madurai - Dindigul',
      'location': 'KM 12/4 - Track Segment',
      'defect': 'Rail Wear & Corrugation',
      'severity': 'Warning',
      'type': 'WARNING',
      'detected': '2026-09-28 09:17',
      'sensor': 'USFD Ultrasonic Rail Tester',
      'impact': 'Grinding required within 14 days',
      'status': 'Scheduled',
    },
    {
      'id': 'ALT-145',
      'asset_code': 'SR-TRK-0145',
      'corridor': 'Chennai - Arakkonam',
      'location': 'KM 124/6 - Track Segment',
      'defect': 'Inspection Completed',
      'severity': 'Info',
      'type': 'INFO',
      'detected': '2026-09-28 08:45',
      'sensor': 'Track Inspection Trolley #04',
      'impact': 'Track condition logged as stable',
      'status': 'Completed',
    },
    {
      'id': 'ALT-021',
      'asset_code': 'SR-TRK-00021',
      'corridor': 'Jolarpettai - Salem',
      'location': 'KM 86/2 - Fish Plate Joint',
      'defect': 'Micro Bolt Tension Loss',
      'severity': 'Warning',
      'type': 'WARNING',
      'detected': '2026-09-27 16:20',
      'sensor': 'GPR Subsurface Ballast Radar',
      'impact': 'Torque retightening assigned to crew',
      'status': 'In Progress',
    },
    {
      'id': 'ALT-009',
      'asset_code': 'SR-TRK-WR009',
      'corridor': 'Mumbai - Ahmedabad (WDFC)',
      'location': 'KM 45/8 - Turnout Point 14A',
      'defect': 'Switch Blade Gap Anomaly 4.2mm',
      'severity': 'Critical',
      'type': 'CRITICAL',
      'detected': '2026-09-27 11:05',
      'sensor': 'DAS Distributed Acoustic Sensor',
      'impact': 'Emergency signal interlock inspection',
      'status': 'Unresolved',
    },
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredAlerts {
    return _alerts.where((a) {
      if (selectedFilter != 'ALL' && a['type'] != selectedFilter) return false;
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final code = (a['asset_code'] ?? '').toString().toLowerCase();
        final def = (a['defect'] ?? '').toString().toLowerCase();
        final loc = (a['location'] ?? '').toString().toLowerCase();
        final cor = (a['corridor'] ?? '').toString().toLowerCase();
        return code.contains(q) || def.contains(q) || loc.contains(q) || cor.contains(q);
      }
      return true;
    }).toList();
  }

  int _countFor(String filter) {
    if (filter == 'ALL') return _alerts.length;
    return _alerts.where((a) => a['type'] == filter).length;
  }

  Color _severityColor(String type) {
    switch (type) {
      case 'CRITICAL':
        return SmartRailTheme.danger;
      case 'WARNING':
        return SmartRailTheme.amber;
      case 'INFO':
        return const Color(0xFF0284C7);
      default:
        return SmartRailTheme.accent;
    }
  }

  IconData _severityIcon(String type) {
    switch (type) {
      case 'CRITICAL':
        return Icons.error_rounded;
      case 'WARNING':
        return Icons.warning_rounded;
      case 'INFO':
        return Icons.info_rounded;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAlerts;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Maintenance Alerts',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read_outlined),
            tooltip: 'Acknowledge All',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All current maintenance alerts marked as acknowledged.'),
                  backgroundColor: Color(0xFF0B1F3A),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (Matching Mockup: All (3), Critical (1), Warning (1), Info (1))
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabChip('ALL', 'All (${_countFor('ALL')})'),
                  const SizedBox(width: 8),
                  _buildTabChip('CRITICAL', 'Critical (${_countFor('CRITICAL')})', isAlert: true),
                  const SizedBox(width: 8),
                  _buildTabChip('WARNING', 'Warning (${_countFor('WARNING')})'),
                  const SizedBox(width: 8),
                  _buildTabChip('INFO', 'Info (${_countFor('INFO')})'),
                ],
              ),
            ),
          ),

          // Search Field
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search alerts by asset ID, defect, location...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 20, color: SmartRailTheme.navy),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),

          // Alert Cards List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline, size: 48, color: Colors.green.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No alerts found',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All track sections within normal parameters',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final alert = filtered[index];
                      final color = _severityColor(alert['type']);
                      final icon = _severityIcon(alert['type']);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: color.withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AssetDetailScreen(
                                    assetCode: alert['asset_code'],
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Icon
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(icon, color: color, size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      // Asset Code & Corridor
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              alert['asset_code'],
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              alert['corridor'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Severity Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          alert['severity'],
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(height: 1),
                                  const SizedBox(height: 10),
                                  // Defect & Details
                                  Row(
                                    children: [
                                      const Text(
                                        'Defect: ',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          alert['defect'],
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Detected: ${alert['detected']}',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const Row(
                                        children: [
                                          Text(
                                            'View Details',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: SmartRailTheme.accent,
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            size: 16,
                                            color: SmartRailTheme.accent,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(String key, String label, {bool isAlert = false}) {
    final isSelected = selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isAlert ? SmartRailTheme.danger : SmartRailTheme.navy)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}
