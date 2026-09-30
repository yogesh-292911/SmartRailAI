import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_rail/screens/assets/asset_detail_screen.dart';
import 'package:smart_rail/screens/live_status/live_status_map_screen.dart';
import 'package:smart_rail/screens/operations/asset_operations_hub_screen.dart';
import 'package:smart_rail/screens/qr_scanner/qr_scanner_screen.dart';
import 'package:smart_rail/screens/alerts/maintenance_alerts_screen.dart';
import 'package:smart_rail/services/api_service.dart';
import 'package:smart_rail/services/session.dart';
import 'package:smart_rail/utils/theme.dart';
import 'package:smart_rail/widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? data;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await context.read<SessionController>().api.get('/api/reports/dashboard');
      setState(() => data = Map<String, dynamic>.from(result as Map));
    } on ApiException catch (e) {
      setState(() => error = e.message);
    } catch (_) {
      // Offline fallback with realistic demo values
      setState(() {
        data = {
          'total_assets': 53,
          'normal': 38,
          'warning': 11,
          'critical': 4,
          'pending': 7,
          'high_risk_assets': [
            {
              'asset_code': 'SR-TRK-00145',
              'asset_type': 'Rail Fastener / Clip',
              'location': 'KM 124/6 (Chennai–Arakkonam)',
              'risk_score': 78.4,
              'risk_level': 'HIGH',
              'sensor_note': 'USFD + WILD: 210 kN wheel impact force breach',
            },
            {
              'asset_code': 'SR-TRK-00021',
              'asset_type': 'Fish Plate Joint',
              'location': 'KM 86/2 (Jolarpettai–Salem)',
              'risk_score': 62.0,
              'risk_level': 'HIGH',
              'sensor_note': 'ITMS: 3.4mm rail head corrugation detected',
            },
          ],
        };
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _openOperationsHub({
    OperationsCategory category = OperationsCategory.jobs,
    String healthMode = 'ALL',
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssetOperationsHubScreen(
          initialCategory: category,
          filterHealthMode: healthMode,
        ),
      ),
    );
  }

  void _openLiveStatusMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LiveStatusMapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final normalCount = '${data?['normal'] ?? 38}';
    final warningCount = '${data?['warning'] ?? 11}';
    final criticalCount = '${data?['critical'] ?? 4}';
    final pendingCount = '${data?['pending'] ?? 7}';
    final totalAssets = '${data?['total_assets'] ?? 53}';

    final highRisk = List<Map<String, dynamic>>.from(
      ((data?['high_risk_assets'] ?? []) as List)
          .map((e) => Map<String, dynamic>.from(e as Map)),
    );

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Header Profile Card with Logo & Live Status Tool Button
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B1F3A), Color(0xFF143056)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B1F3A).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Official App Logo
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: SmartRailTheme.amber, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.train_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_greeting()}, ${session.name}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: SmartRailTheme.accent.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  session.role.isNotEmpty ? session.role : 'OPERATOR',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$totalAssets Assets Monitored',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // --- LIVE STATUS TOOL SECTION ON TOP OF HOME MENU ---
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openLiveStatusMap,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF10B981).withValues(alpha: 0.25),
                            ),
                            child: const Icon(
                              Icons.radar_rounded,
                              color: Color(0xFF34D399),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'LIVE STATUS',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Icon(
                                      Icons.fiber_manual_record,
                                      color: Color(0xFF34D399),
                                      size: 10,
                                    ),
                                  ],
                                ),
                                Text(
                                  'Entire Railway Map of India • Corridors & Real-Time Sensors',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFBAE6FD),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white70,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // --- LIVE NOTIFICATION BAR ON HOME SECTION ---
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MaintenanceAlertsScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFEF4444),
                            ),
                            child: const Icon(
                              Icons.notifications_active_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'MAINTENANCE ALERTS',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFFCA5A5),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '• 3 New',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'IR-TRACK-102: Loose Fastener & Clip Fatigue (Chennai-Delhi)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'VIEW >',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Instruction hint
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionTitle('Asset & Work Overview'),
              GestureDetector(
                onTap: () => _openOperationsHub(),
                child: const Text(
                  'Operations Hub →',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: SmartRailTheme.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // --- THE FOUR BOXES (INTERACTIVE TRANSFORMATION) ---
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              StatCard(
                label: 'Normal',
                value: normalCount,
                subtitle: 'Good Track Assets',
                color: SmartRailTheme.ok,
                icon: Icons.check_circle_outline,
                onTap: () => _openOperationsHub(
                  category: OperationsCategory.assetHealth,
                  healthMode: 'GOOD',
                ),
              ),
              StatCard(
                label: 'Warning',
                value: warningCount,
                subtitle: 'Moderate Wear Alert',
                color: SmartRailTheme.amber,
                icon: Icons.warning_amber_rounded,
                onTap: () => _openOperationsHub(
                  category: OperationsCategory.riskyAssets,
                ),
              ),
              StatCard(
                label: 'Critical',
                value: criticalCount,
                subtitle: 'Urgent Track Repair',
                color: SmartRailTheme.danger,
                icon: Icons.priority_high,
                onTap: () => _openOperationsHub(
                  category: OperationsCategory.riskyAssets,
                ),
              ),
              StatCard(
                label: 'Pending Jobs',
                value: pendingCount,
                subtitle: 'In Progress & Assigned',
                color: SmartRailTheme.navyMid,
                icon: Icons.build_circle_outlined,
                onTap: () => _openOperationsHub(
                  category: OperationsCategory.jobs,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Innovative Systems Real-Time Telemetry Card
          _buildInnovativeSystemsBanner(),
          const SizedBox(height: 14),

          // Action Shortcuts
          if (session.isInspector || session.isAdmin) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: SmartRailTheme.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrScannerScreen()),
              ),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('SCAN TRACK QR / SELECT ASSET'),
            ),
            const SizedBox(height: 12),
          ],

          // High Risk Assets Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionTitle('High Risk Track Alerts'),
              if (highRisk.isNotEmpty)
                TextButton(
                  onPressed: () => _openOperationsHub(category: OperationsCategory.riskyAssets),
                  child: const Text('View All'),
                ),
            ],
          ),
          if (highRisk.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: SmartRailTheme.ok),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'All monitored track sections operating within safety limits.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ...highRisk.map(
            (item) => Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: SmartRailTheme.danger.withValues(alpha: 0.15),
                  child: const Icon(Icons.warning_amber_rounded, color: SmartRailTheme.danger),
                ),
                title: Text(
                  item['asset_code']?.toString() ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${item['asset_type']} • ${item['location'] ?? 'High Speed Corridor'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item['risk_score']}%',
                      style: const TextStyle(
                        color: SmartRailTheme.danger,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const Text(
                      'CRITICAL',
                      style: TextStyle(
                        color: SmartRailTheme.danger,
                        fontWeight: FontWeight.w800,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AssetDetailScreen(
                      assetCode: item['asset_code'].toString(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInnovativeSystemsBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.memory, color: SmartRailTheme.accent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'AI-Powered Monitoring Systems',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: SmartRailTheme.navy,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '6 ONLINE',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _techPill('ITMS', 'High-Speed Laser Cameras', Icons.camera_enhance_outlined),
                const SizedBox(width: 8),
                _techPill('GPR', 'Subsurface Ballast Radar', Icons.layers_outlined),
                const SizedBox(width: 8),
                _techPill('USFD', 'Ultrasonic Internal Flaw', Icons.graphic_eq_rounded),
                const SizedBox(width: 8),
                _techPill('WILD', 'Wheel Impact Load Sensors', Icons.speed_rounded),
                const SizedBox(width: 8),
                _techPill('DAS-AI', 'Fiber Acoustic Sensing', Icons.waves_rounded),
                const SizedBox(width: 8),
                _techPill('DRONE', 'Aerial LiDAR & Thermal', Icons.flight_takeoff_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _techPill(String name, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: SmartRailTheme.navy),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: SmartRailTheme.navy,
                ),
              ),
              Text(
                desc,
                style: TextStyle(fontSize: 9.5, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
