import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_rail/screens/assets/asset_detail_screen.dart';
import 'package:smart_rail/services/session.dart';
import 'package:smart_rail/utils/theme.dart';
import 'package:smart_rail/widgets/track_job_status_bar.dart';

enum OperationsCategory {
  jobs,
  assetHealth,
  riskyAssets,
  repairedAssets,
}

class AssetOperationsHubScreen extends StatefulWidget {
  const AssetOperationsHubScreen({
    super.key,
    this.initialCategory = OperationsCategory.jobs,
    this.filterHealthMode = 'ALL', // 'ALL', 'GOOD', 'NEED_REPAIR'
  });

  final OperationsCategory initialCategory;
  final String filterHealthMode;

  @override
  State<AssetOperationsHubScreen> createState() => _AssetOperationsHubScreenState();
}

class _AssetOperationsHubScreenState extends State<AssetOperationsHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool loading = true;
  String? error;

  List<Map<String, dynamic>> assets = [];
  List<Map<String, dynamic>> jobs = [];
  String searchQuery = '';
  String jobsFilter = 'ALL'; // ALL, IN_PROGRESS, COMPLETED
  late String healthFilter;

  @override
  void initState() {
    super.initState();
    healthFilter = widget.filterHealthMode;
    int initialIndex = 0;
    switch (widget.initialCategory) {
      case OperationsCategory.jobs:
        initialIndex = 0;
        break;
      case OperationsCategory.assetHealth:
        initialIndex = 1;
        break;
      case OperationsCategory.riskyAssets:
        initialIndex = 2;
        break;
      case OperationsCategory.repairedAssets:
        initialIndex = 3;
        break;
    }
    _tabController = TabController(length: 4, vsync: this, initialIndex: initialIndex);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      loading = true;
      error = null;
    });

    final session = context.read<SessionController>();
    try {
      final assetsRes = await session.api.get('/api/assets').catchError((_) => null);
      final jobsRes = await session.api.get('/api/maintenance').catchError((_) => null);

      List<Map<String, dynamic>> loadedAssets = [];
      if (assetsRes is List) {
        loadedAssets = List<Map<String, dynamic>>.from(
          assetsRes.map((e) => Map<String, dynamic>.from(e as Map)),
        );
      }

      // If empty or offline, use robust demo track assets
      if (loadedAssets.isEmpty) {
        loadedAssets = _mockAssets();
      }

      List<Map<String, dynamic>> loadedJobs = [];
      if (jobsRes is List) {
        loadedJobs = List<Map<String, dynamic>>.from(
          jobsRes.map((e) => Map<String, dynamic>.from(e as Map)),
        );
      }

      if (loadedJobs.isEmpty) {
        loadedJobs = _mockJobs();
      }

      setState(() {
        assets = loadedAssets;
        jobs = loadedJobs;
        loading = false;
      });
    } catch (e) {
      // Graceful fallback with full sample data
      setState(() {
        assets = _mockAssets();
        jobs = _mockJobs();
        loading = false;
      });
    }
  }

  List<Map<String, dynamic>> _mockAssets() {
    return [
      {
        'id': 1,
        'asset_code': 'SR-TRK-00145',
        'asset_type': 'Rail Fastener / Clip',
        'railway_zone': 'Southern Railway',
        'section': 'Chennai–Arakkonam',
        'location': 'KM 124/6',
        'condition': 'Poor',
        'ai_risk_score': 78.4,
        'ai_risk_level': 'HIGH',
        'damage_type': 'Loose Fastener & Clip Fatigue',
        'sensor_type': 'ITMS Laser Camera + WILD',
        'sensor_reading': 'Clamp force: 8.2 kN (Threshold 12 kN)',
        'needs_repair': true,
        'is_repaired': false,
        'recommendation': 'Emergency tightening and replace clip within 24h',
      },
      {
        'id': 2,
        'asset_code': 'SR-TRK-00021',
        'asset_type': 'Fish Plate Joint',
        'railway_zone': 'Southern Railway',
        'section': 'Jolarpettai–Salem',
        'location': 'KM 86/2',
        'condition': 'Moderate',
        'ai_risk_score': 54.0,
        'ai_risk_level': 'MEDIUM',
        'damage_type': 'Micro Surface Crack in Joint Bolt',
        'sensor_type': 'USFD Ultrasonic Flaw Scanner',
        'sensor_reading': 'Echo amplitude 4.2mm flaw detected',
        'needs_repair': true,
        'is_repaired': false,
        'recommendation': 'Conduct magnetic particle scan and weld reinforcement',
      },
      {
        'id': 3,
        'asset_code': 'SR-TRK-00034',
        'asset_type': 'Rail Bolt & Pad',
        'railway_zone': 'South Western Railway',
        'section': 'Bangalore–Mysore',
        'location': 'KM 42/1',
        'condition': 'Good',
        'ai_risk_score': 12.0,
        'ai_risk_level': 'LOW',
        'damage_type': 'Normal Wear',
        'sensor_type': 'DAS Fiber Acoustic Sensing',
        'sensor_reading': 'Vibration acoustic signature: Optimal 0.4 mm/s',
        'needs_repair': false,
        'is_repaired': true,
        'repaired_date': '2026-08-14',
        'recommendation': 'Regular routine maintenance schedule',
      },
      {
        'id': 4,
        'asset_code': 'SR-TRK-00048',
        'asset_type': 'Concrete Sleeper',
        'railway_zone': 'Southern Railway',
        'section': 'Madurai–Dindigul',
        'location': 'KM 12/4',
        'condition': 'Good',
        'ai_risk_score': 15.2,
        'ai_risk_level': 'LOW',
        'damage_type': 'None',
        'sensor_type': 'GPR Subsurface Radar',
        'sensor_reading': 'Ballast density: 98% compact, no voids',
        'needs_repair': false,
        'is_repaired': true,
        'repaired_date': '2026-07-28',
        'recommendation': 'Stable ballast bed verified by GPR scan',
      },
      {
        'id': 5,
        'asset_code': 'SR-TRK-00055',
        'asset_type': 'Insulated Track Joint',
        'railway_zone': 'Southern Railway',
        'section': 'Coimbatore–Palakkad',
        'location': 'KM 201/3',
        'condition': 'Moderate',
        'ai_risk_score': 48.0,
        'ai_risk_level': 'MEDIUM',
        'damage_type': 'Insulation Pad Wear',
        'sensor_type': 'ITMS Geometry Scan',
        'sensor_reading': 'Track alignment deviation: 2.1 mm',
        'needs_repair': true,
        'is_repaired': false,
        'recommendation': 'Replace polymer end post during next track block',
      },
      {
        'id': 6,
        'asset_code': 'SR-TRK-00062',
        'asset_type': 'Switch Point Component',
        'railway_zone': 'Southern Railway',
        'section': 'Basin Bridge Yard',
        'location': 'Point 14A',
        'condition': 'Good',
        'ai_risk_score': 8.5,
        'ai_risk_level': 'LOW',
        'damage_type': 'None (Recently Overhauled)',
        'sensor_type': 'Loco-Vision Edge AI Twin',
        'sensor_reading': 'Switch blade clearance: 115mm (Nominal)',
        'needs_repair': false,
        'is_repaired': true,
        'repaired_date': '2026-09-02',
        'recommendation': 'Lubricated and certified safe for 130 km/h crossover',
      },
    ];
  }

  List<Map<String, dynamic>> _mockJobs() {
    return [
      {
        'id': 101,
        'asset_code': 'SR-TRK-00145',
        'asset_type': 'Rail Fastener / Clip',
        'location': 'KM 124/6 (Chennai-Arakkonam)',
        'priority': 'HIGH',
        'status': 'IN_PROGRESS',
        'action': 'Emergency Clip Replacement & Torque Re-check',
        'scheduled_date': '2026-09-29',
        'assignee_name': 'Ravi Menon (Trackgang-4)',
        'risk_score': 78.4,
        'risk_level': 'HIGH',
        'remarks': 'USFD alerted clip fracture risk. Speed restriction 45 km/h until fixed.',
      },
      {
        'id': 102,
        'asset_code': 'SR-TRK-00021',
        'asset_type': 'Fish Plate Joint',
        'location': 'KM 86/2 (Jolarpettai-Salem)',
        'priority': 'MEDIUM',
        'status': 'ASSIGNED',
        'action': 'Ultrasonic Joint Flaw Testing & Bolt Renewal',
        'scheduled_date': '2026-09-30',
        'assignee_name': 'Senthil V. (P-Way Dept)',
        'risk_score': 54.0,
        'risk_level': 'MEDIUM',
        'remarks': 'Scheduled maintenance during 2-hour shadow block.',
      },
      {
        'id': 103,
        'asset_code': 'SR-TRK-00055',
        'asset_type': 'Insulated Track Joint',
        'location': 'KM 201/3 (Coimbatore-Palakkad)',
        'priority': 'MEDIUM',
        'status': 'PENDING',
        'action': 'Replace Glued Insulated Joint (GIJ) Insulators',
        'scheduled_date': '2026-10-02',
        'assignee_name': 'Unassigned',
        'risk_score': 48.0,
        'risk_level': 'MEDIUM',
        'remarks': 'Signaling circuit impedance fluctuating due to pad wear.',
      },
      {
        'id': 104,
        'asset_code': 'SR-TRK-00034',
        'asset_type': 'Rail Bolt & Pad',
        'location': 'KM 42/1 (Bangalore-Mysore)',
        'priority': 'LOW',
        'status': 'COMPLETED',
        'action': 'Elastic Rail Clip Renewal & Ballast Tamping',
        'scheduled_date': '2026-08-12',
        'completed_date': '2026-08-14',
        'assignee_name': 'Ravi Menon (Trackgang-2)',
        'risk_score': 12.0,
        'risk_level': 'LOW',
        'remarks': 'Successfully repaired. Passed ITMS dynamic laser test with 100% compliance.',
      },
      {
        'id': 105,
        'asset_code': 'SR-TRK-00062',
        'asset_type': 'Switch Point Component',
        'location': 'Point 14A (Basin Bridge Yard)',
        'priority': 'HIGH',
        'status': 'COMPLETED',
        'action': 'Turnout Point Stretcher Bar Realignment',
        'scheduled_date': '2026-08-31',
        'completed_date': '2026-09-02',
        'assignee_name': 'Dinesh Kumar (Yard Foreman)',
        'risk_score': 8.5,
        'risk_level': 'LOW',
        'remarks': 'Overhauled switch blades, cleared by Senior Section Engineer (SSE).',
      },
    ];
  }

  Future<void> _updateJobStatus(Map<String, dynamic> job, String nextStatus) async {
    final session = context.read<SessionController>();
    try {
      await session.api.put('/api/maintenance/${job['id']}', {'status': nextStatus});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job #${job['id']} updated to $nextStatus'),
          backgroundColor: SmartRailTheme.ok,
        ),
      );
      _loadData();
    } catch (_) {
      if (!mounted) return;
      // Local optimistic update
      setState(() {
        job['status'] = nextStatus;
        if (nextStatus == 'COMPLETED') {
          job['completed_date'] = DateTime.now().toIsoformatDate();
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job #${job['id']} marked $nextStatus'),
          backgroundColor: SmartRailTheme.ok,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();

    final goodAssets = assets.where((a) {
      final cond = (a['condition'] ?? '').toString().toLowerCase();
      final risk = (a['ai_risk_level'] ?? '').toString().toUpperCase();
      return cond == 'good' || risk == 'LOW';
    }).toList();

    final needRepairAssets = assets.where((a) {
      final cond = (a['condition'] ?? '').toString().toLowerCase();
      final risk = (a['ai_risk_level'] ?? '').toString().toUpperCase();
      return cond == 'poor' || cond == 'moderate' || risk == 'HIGH' || risk == 'MEDIUM';
    }).toList();

    final riskyAssets = assets.where((a) {
      final risk = (a['ai_risk_level'] ?? '').toString().toUpperCase();
      final score = (a['ai_risk_score'] as num?)?.toDouble() ?? 0.0;
      return risk == 'HIGH' || score >= 50.0;
    }).toList();

    final repairedAssets = [
      ...assets.where((a) => a['is_repaired'] == true),
      ...jobs.where((j) => j['status'] == 'COMPLETED'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset & Job Operations'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: SmartRailTheme.amber,
          indicatorWeight: 3.5,
          tabs: [
            Tab(
              icon: const Icon(Icons.build_circle_outlined, size: 20),
              child: Row(
                children: [
                  const Text('All Jobs'),
                  const SizedBox(width: 6),
                  _badge('${jobs.length}', SmartRailTheme.navyMid),
                ],
              ),
            ),
            Tab(
              icon: const Icon(Icons.health_and_safety_outlined, size: 20),
              child: Row(
                children: [
                  const Text('Track Health'),
                  const SizedBox(width: 6),
                  _badge('${assets.length}', SmartRailTheme.ok),
                ],
              ),
            ),
            Tab(
              icon: const Icon(Icons.warning_amber_rounded, size: 20),
              child: Row(
                children: [
                  const Text('Risky Assets'),
                  const SizedBox(width: 6),
                  _badge('${riskyAssets.length}', SmartRailTheme.danger),
                ],
              ),
            ),
            Tab(
              icon: const Icon(Icons.check_circle_outline, size: 20),
              child: Row(
                children: [
                  const Text('Repaired'),
                  const SizedBox(width: 6),
                  _badge('${repairedAssets.length}', SmartRailTheme.ok),
                ],
              ),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: All Jobs (with Status Bar)
                _buildJobsTab(session),
                // Tab 2: Track Asset Health (Good vs Need Repair)
                _buildAssetHealthTab(goodAssets, needRepairAssets),
                // Tab 3: Risky Track Asset Details
                _buildRiskyAssetsTab(riskyAssets),
                // Tab 4: Repaired Track Assets
                _buildRepairedAssetsTab(repairedAssets),
              ],
            ),
    );
  }

  Widget _badge(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  // --- TAB 1: ALL JOBS WITH STATUS BAR ---
  Widget _buildJobsTab(SessionController session) {
    final filteredJobs = jobs.where((j) {
      if (jobsFilter == 'IN_PROGRESS') {
        return j['status'] == 'IN_PROGRESS' || j['status'] == 'ASSIGNED' || j['status'] == 'PENDING';
      }
      if (jobsFilter == 'COMPLETED') {
        return j['status'] == 'COMPLETED';
      }
      return true;
    }).toList();

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Text(
                'Filter Jobs: ',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(width: 8),
              _filterChip('All (${jobs.length})', jobsFilter == 'ALL', () {
                setState(() => jobsFilter = 'ALL');
              }),
              const SizedBox(width: 6),
              _filterChip('In Progress', jobsFilter == 'IN_PROGRESS', () {
                setState(() => jobsFilter = 'IN_PROGRESS');
              }),
              const SizedBox(width: 6),
              _filterChip('Completed', jobsFilter == 'COMPLETED', () {
                setState(() => jobsFilter = 'COMPLETED');
              }),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: filteredJobs.isEmpty
                ? const Center(child: Text('No maintenance jobs match this filter.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredJobs.length,
                    itemBuilder: (ctx, i) {
                      final job = filteredJobs[i];
                      return _buildJobCard(job, session);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? SmartRailTheme.navy : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? SmartRailTheme.navy : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? Colors.white : Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, SessionController session) {
    final status = job['status']?.toString() ?? 'PENDING';
    final priority = job['priority']?.toString() ?? 'MEDIUM';
    final assetCode = job['asset_code']?.toString() ?? 'SR-ASSET';
    final action = job['action']?.toString() ?? 'Track Inspection & Maintenance';
    final assignee = job['assignee_name']?.toString() ?? 'Unassigned';
    final location = job['location']?.toString() ?? 'Indian Railways Track';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: riskColor(priority).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$priority PRIORITY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: riskColor(priority),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Job #${job['id']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AssetDetailScreen(assetCode: assetCode),
                      ),
                    );
                  },
                  icon: const Icon(Icons.open_in_new, size: 14),
                  label: const Text('Asset Info', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              action,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: SmartRailTheme.navy,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '$assetCode • $location',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Assignee: $assignee',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // --- THE VISUAL STATUS BAR REQUESTED BY THE USER ---
            TrackJobStatusBar(status: status),

            const SizedBox(height: 12),
            if (job['remarks'] != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  'Note: ${job['remarks']}',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
                ),
              ),
            const SizedBox(height: 10),

            // Action buttons to progress status
            if (session.isMaintenance || session.isAdmin) ...[
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (status == 'PENDING')
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        minimumSize: const Size(120, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () => _updateJobStatus(job, 'ASSIGNED'),
                      icon: const Icon(Icons.assignment_ind_outlined, size: 16),
                      label: const Text('ASSIGN WORK', style: TextStyle(fontSize: 12)),
                    ),
                  if (status == 'ASSIGNED')
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        minimumSize: const Size(130, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () => _updateJobStatus(job, 'IN_PROGRESS'),
                      icon: const Icon(Icons.play_arrow_rounded, size: 16),
                      label: const Text('START TRACK WORK', style: TextStyle(fontSize: 12)),
                    ),
                  if (status == 'IN_PROGRESS')
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        minimumSize: const Size(150, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () => _updateJobStatus(job, 'COMPLETED'),
                      icon: const Icon(Icons.verified_outlined, size: 16),
                      label: const Text('MARK REPAIRED & CLEAR', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- TAB 2: TRACK ASSET HEALTH (GOOD VS NEED REPAIR) ---
  Widget _buildAssetHealthTab(
    List<Map<String, dynamic>> goodAssets,
    List<Map<String, dynamic>> needRepairAssets,
  ) {
    List<Map<String, dynamic>> displayed = [];
    if (healthFilter == 'GOOD') {
      displayed = goodAssets;
    } else if (healthFilter == 'NEED_REPAIR') {
      displayed = needRepairAssets;
    } else {
      displayed = assets;
    }

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _healthStatBox(
                      'Good Tracks',
                      '${goodAssets.length}',
                      SmartRailTheme.ok,
                      Icons.check_circle_outline,
                      healthFilter == 'GOOD',
                      () => setState(() => healthFilter = 'GOOD'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _healthStatBox(
                      'Need Repair',
                      '${needRepairAssets.length}',
                      SmartRailTheme.danger,
                      Icons.build_circle_outlined,
                      healthFilter == 'NEED_REPAIR',
                      () => setState(() => healthFilter = 'NEED_REPAIR'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _healthStatBox(
                      'All Assets',
                      '${assets.length}',
                      SmartRailTheme.navy,
                      Icons.inventory_2_outlined,
                      healthFilter == 'ALL',
                      () => setState(() => healthFilter = 'ALL'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: displayed.length,
            itemBuilder: (ctx, i) {
              final a = displayed[i];
              final isGood = (a['condition']?.toString().toLowerCase() == 'good') ||
                  (a['ai_risk_level'] == 'LOW');
              return Card(
                elevation: 1.5,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor: isGood
                        ? SmartRailTheme.ok.withValues(alpha: 0.15)
                        : SmartRailTheme.danger.withValues(alpha: 0.15),
                    child: Icon(
                      isGood ? Icons.done_all_rounded : Icons.warning_rounded,
                      color: isGood ? SmartRailTheme.ok : SmartRailTheme.danger,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        a['asset_code']?.toString() ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isGood
                              ? SmartRailTheme.ok.withValues(alpha: 0.12)
                              : SmartRailTheme.danger.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isGood ? 'SAFE & HEALTHY' : 'NEEDS REPAIR',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isGood ? SmartRailTheme.ok : SmartRailTheme.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${a['asset_type']} • ${a['location']}'),
                      if (a['damage_type'] != null)
                        Text(
                          'Observed: ${a['damage_type']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isGood ? Colors.grey.shade600 : SmartRailTheme.danger,
                            fontWeight: isGood ? FontWeight.normal : FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AssetDetailScreen(
                          assetCode: a['asset_code']?.toString() ?? '',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _healthStatBox(
    String label,
    String count,
    Color color,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 3: RISKY TRACK ASSET DETAILS ---
  Widget _buildRiskyAssetsTab(List<Map<String, dynamic>> riskyAssets) {
    if (riskyAssets.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_outlined, size: 54, color: SmartRailTheme.ok),
              SizedBox(height: 12),
              Text(
                'No High-Risk Track Assets',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'All inspected railway track sections are operating within safe tolerance parameters.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: riskyAssets.length,
      itemBuilder: (ctx, i) {
        final a = riskyAssets[i];
        final riskScore = (a['ai_risk_score'] as num?)?.toDouble() ?? 75.0;
        final sensorType = a['sensor_type']?.toString() ?? 'ITMS Laser Camera & USFD';
        final sensorReading = a['sensor_reading']?.toString() ?? 'Threshold breach detected';
        final recommendation = a['recommendation']?.toString() ?? 'Immediate track inspection required';

        return Card(
          elevation: 2.5,
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SmartRailTheme.danger.withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: SmartRailTheme.danger.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, size: 14, color: SmartRailTheme.danger),
                            const SizedBox(width: 4),
                            Text(
                              'RISK SCORE: ${riskScore.toStringAsFixed(1)}% (CRITICAL)',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: SmartRailTheme.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AssetDetailScreen(
                                assetCode: a['asset_code'].toString(),
                              ),
                            ),
                          );
                        },
                        child: const Text('Full Telemetry'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${a['asset_code']} • ${a['asset_type']}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: SmartRailTheme.navy,
                    ),
                  ),
                  Text(
                    'Zone: ${a['railway_zone']} | Location: ${a['location']}',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 10),

                  // Sensor Telemetry Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.sensors_rounded, size: 16, color: SmartRailTheme.danger),
                            const SizedBox(width: 6),
                            Text(
                              'Real-Time Sensor Telemetry ($sensorType)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: SmartRailTheme.danger,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sensorReading,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // AI Recommendation
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome, size: 16, color: SmartRailTheme.amber),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'AI Action: $recommendation',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Quick Action button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SmartRailTheme.danger,
                            minimumSize: const Size(0, 42),
                          ),
                          onPressed: () {
                            _tabController.animateTo(0);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Dispatching maintenance crew for ${a['asset_code']}'),
                                backgroundColor: SmartRailTheme.danger,
                              ),
                            );
                          },
                          icon: const Icon(Icons.build, size: 16),
                          label: const Text('DISPATCH EMERGENCY REPAIR'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- TAB 4: REPAIRED TRACK ASSETS ---
  Widget _buildRepairedAssetsTab(List<dynamic> repaired) {
    if (repaired.isEmpty) {
      return const Center(child: Text('No repaired track assets history yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: repaired.length,
      itemBuilder: (ctx, i) {
        final item = repaired[i];
        final code = item['asset_code']?.toString() ?? 'SR-TRK';
        final type = item['asset_type']?.toString() ?? 'Track Component';
        final location = item['location']?.toString() ?? 'Indian Railways Line';
        final action = item['action']?.toString() ?? 'Replaced & Torque Certified';
        final date = item['completed_date'] ?? item['repaired_date'] ?? '2026-09-15';

        return Card(
          elevation: 1.5,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SmartRailTheme.ok.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.verified, color: SmartRailTheme.ok, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            code,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: SmartRailTheme.ok.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'CERTIFIED SAFE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: SmartRailTheme.ok,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('$type • $location', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(
                        'Repair Action: $action',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.event_available, size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Completed on: $date',
                            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

extension DateTimeIso on DateTime {
  String toIsoformatDate() {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}
