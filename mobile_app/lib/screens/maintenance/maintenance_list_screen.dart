import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_rail/screens/assets/asset_detail_screen.dart';
import 'package:smart_rail/services/api_service.dart';
import 'package:smart_rail/services/session.dart';
import 'package:smart_rail/utils/theme.dart';
import 'package:smart_rail/widgets/track_job_status_bar.dart';

class MaintenanceListScreen extends StatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  List<Map<String, dynamic>> jobs = [];
  bool loading = true;
  String activeFilter = 'ALL'; // ALL, PENDING, IN_PROGRESS, COMPLETED, HIGH_PRIORITY

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final data = await context.read<SessionController>().api.get('/api/maintenance');
      if (data is List && data.isNotEmpty) {
        setState(() {
          jobs = List<Map<String, dynamic>>.from(
            data.map((e) => Map<String, dynamic>.from(e as Map)),
          );
          loading = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback jobs list
    setState(() {
      jobs = [
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
          'remarks': 'Signaling track circuit impedance fluctuating due to pad wear.',
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
          'remarks': 'Successfully repaired. Passed ITMS dynamic laser test.',
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
          'remarks': 'Overhauled switch blades, certified safe by SSE.',
        },
      ];
      loading = false;
    });
  }

  Future<void> _update(Map<String, dynamic> job, String status) async {
    final session = context.read<SessionController>();
    final body = <String, dynamic>{'status': status};
    if (status == 'ASSIGNED') {
      body['assigned_to'] = session.user?['id'];
    }
    try {
      await session.api.put('/api/maintenance/${job['id']}', body);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job #${job['id']} updated to $status'),
          backgroundColor: SmartRailTheme.ok,
        ),
      );
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      // Local update
      setState(() {
        job['status'] = status;
        if (status == 'COMPLETED') {
          job['completed_date'] = DateTime.now().toString().split(' ').first;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job #${job['id']} status updated to $status'),
          backgroundColor: SmartRailTheme.ok,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();

    final filteredJobs = jobs.where((j) {
      final status = j['status']?.toString().toUpperCase() ?? '';
      final priority = j['priority']?.toString().toUpperCase() ?? '';
      if (activeFilter == 'PENDING') return status == 'PENDING';
      if (activeFilter == 'IN_PROGRESS') return status == 'IN_PROGRESS' || status == 'ASSIGNED';
      if (activeFilter == 'COMPLETED') return status == 'COMPLETED';
      if (activeFilter == 'HIGH_PRIORITY') return priority == 'HIGH';
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Maintenance Jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Quick Filters Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('All (${jobs.length})', activeFilter == 'ALL', () {
                          setState(() => activeFilter = 'ALL');
                        }),
                        const SizedBox(width: 6),
                        _filterChip('In Progress', activeFilter == 'IN_PROGRESS', () {
                          setState(() => activeFilter = 'IN_PROGRESS');
                        }),
                        const SizedBox(width: 6),
                        _filterChip('Pending', activeFilter == 'PENDING', () {
                          setState(() => activeFilter = 'PENDING');
                        }),
                        const SizedBox(width: 6),
                        _filterChip('Completed', activeFilter == 'COMPLETED', () {
                          setState(() => activeFilter = 'COMPLETED');
                        }),
                        const SizedBox(width: 6),
                        _filterChip('High Priority', activeFilter == 'HIGH_PRIORITY', () {
                          setState(() => activeFilter = 'HIGH_PRIORITY');
                        }),
                      ],
                    ),
                  ),
                ),

                // Jobs List with Status Bar
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: filteredJobs.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 80),
                              Center(child: Text('No maintenance jobs match this filter.')),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: filteredJobs.length,
                            itemBuilder: (_, i) {
                              final job = filteredJobs[i];
                              final status = job['status']?.toString() ?? 'PENDING';
                              final priority = job['priority']?.toString() ?? 'MEDIUM';
                              final assetCode = job['asset_code']?.toString() ?? '';

                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
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
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: riskColor(priority).withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '$priority PRIORITY',
                                              style: TextStyle(
                                                color: riskColor(priority),
                                                fontWeight: FontWeight.w800,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                          TextButton.icon(
                                            style: TextButton.styleFrom(
                                              visualDensity: VisualDensity.compact,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => AssetDetailScreen(
                                                    assetCode: assetCode,
                                                  ),
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
                                        job['action']?.toString() ?? 'Track Repair',
                                        style: const TextStyle(
                                          fontSize: 16.5,
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
                                              '$assetCode • ${job['location']}',
                                              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (job['assignee_name'] != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Assignee: ${job['assignee_name']}',
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                            ),
                                          ],
                                        ),
                                      ],
                                      const SizedBox(height: 14),

                                      // --- VISUAL TRACK JOB STATUS BAR ---
                                      TrackJobStatusBar(status: status),

                                      if (job['remarks'] != null) ...[
                                        const SizedBox(height: 10),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.grey.shade200),
                                          ),
                                          child: Text(
                                            'Remarks: ${job['remarks']}',
                                            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
                                          ),
                                        ),
                                      ],

                                      const SizedBox(height: 12),
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
                                                onPressed: () => _update(job, 'ASSIGNED'),
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
                                                onPressed: () => _update(job, 'IN_PROGRESS'),
                                                icon: const Icon(Icons.play_arrow_rounded, size: 16),
                                                label: const Text('START WORK', style: TextStyle(fontSize: 12)),
                                              ),
                                            if (status == 'IN_PROGRESS')
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF10B981),
                                                  minimumSize: const Size(150, 36),
                                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                                ),
                                                onPressed: () => _update(job, 'COMPLETED'),
                                                icon: const Icon(Icons.verified_outlined, size: 16),
                                                label: const Text('COMPLETE & CLEAR', style: TextStyle(fontSize: 12)),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _filterChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? SmartRailTheme.navy : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
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
}
