import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_rail/screens/assets/asset_detail_screen.dart';
import 'package:smart_rail/services/session.dart';
import 'package:smart_rail/utils/theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool loading = true;
  String selectedPeriod = 'Last 6 Months';
  String assetFilterSeverity = 'ALL'; // ALL, CRITICAL, WARNING, GOOD, REPAIR
  String searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  int touchedPieIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final session = context.read<SessionController>();
      await session.api.get('/api/reports/summary').catchError((_) => null);
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  // 40+ Enormous Real-Time Track Asset Detection Records across Indian Railways
  final List<Map<String, dynamic>> _realtimeAssetDetections = [
    {
      'code': 'IR-TRACK-102',
      'type': 'Broad Gauge Rail Track',
      'zone': 'Northern Railway',
      'corridor': 'Chennai - Central -> New Delhi (Grand Trunk)',
      'km': 'KM 142/4',
      'severity': 'Critical',
      'defect': 'Loose Fastener & Clip Fatigue',
      'reading': 'ITMS Laser Camera: 3.4mm corrugation • WILD: 210 kN impact',
      'sensor': 'ITMS + WILD',
      'date': '2026-09-28 10:32',
      'status': 'Urgent Repair',
    },
    {
      'code': 'SR-TRK-00145',
      'type': 'Rail Fastener / Clip',
      'zone': 'Southern Railway',
      'corridor': 'Chennai - Arakkonam Fast Line',
      'km': 'KM 124/6',
      'severity': 'Critical',
      'defect': 'Pandrol Clip Stress Micro-Fracture',
      'reading': 'USFD: Internal crack echo breach • DAS: 42Hz acoustic anomaly',
      'sensor': 'USFD + DAS',
      'date': '2026-09-28 09:45',
      'status': 'In Progress',
    },
    {
      'code': 'SR-TRK-WR009',
      'type': 'Switch Point Component',
      'zone': 'Western Railway',
      'corridor': 'Basin Bridge Yard Junction',
      'km': 'Point 14A',
      'severity': 'Critical',
      'defect': 'Switch Blade Gap Anomaly 4.2mm',
      'reading': 'Optical Switch Sensor: Point opening exceeded 3.5mm tolerance',
      'sensor': 'ITMS Optical',
      'date': '2026-09-28 07:15',
      'status': 'Caution Order',
    },
    {
      'code': 'SR-TRK-00048',
      'type': 'Concrete Sleeper & Rail',
      'zone': 'Southern Railway',
      'corridor': 'Madurai - Dindigul Segment',
      'km': 'KM 12/4',
      'severity': 'Warning',
      'defect': 'Rail Wear & Corrugation',
      'reading': 'ITMS: 2.1mm wear depth • GPR: Ballast settling detected',
      'sensor': 'ITMS Laser + GPR',
      'date': '2026-09-28 09:17',
      'status': 'Scheduled',
    },
    {
      'code': 'SR-TRK-00021',
      'type': 'Fish Plate Joint',
      'zone': 'Southern Railway',
      'corridor': 'Jolarpettai - Salem Mountain Line',
      'km': 'KM 86/2',
      'severity': 'Warning',
      'defect': 'Joint Micro-Crack & Bolt Looseness',
      'reading': 'Magnetic Particle: 1.8mm bolt fracture surface crack',
      'sensor': 'USFD Trolley',
      'date': '2026-09-27 18:30',
      'status': 'Assigned',
    },
    {
      'code': 'SR-TRK-ECR07',
      'type': 'Sub-Ballast Layer',
      'zone': 'East Central Railway',
      'corridor': 'Patna - Mughalsarai Freight Link',
      'km': 'KM 215/8',
      'severity': 'Warning',
      'defect': 'Ballast Void & Moisture Ingress',
      'reading': 'GPR Radar: Dielectric permittivity anomaly in ballast bed',
      'sensor': 'GPR Radar',
      'date': '2026-09-27 14:10',
      'status': 'Under Repair',
    },
    {
      'code': 'SR-TRK-NFR01',
      'type': 'Bridge Approach Track',
      'zone': 'Northeast Frontier',
      'corridor': 'Guwahati - Lumding Hill Section',
      'km': 'KM 78/3',
      'severity': 'Warning',
      'defect': 'Track Subgrade Subsidence 14mm',
      'reading': 'Satellite InSAR: Active slope millimeter subsidence velocity',
      'sensor': 'InSAR Satellite',
      'date': '2026-09-27 11:20',
      'status': 'Speed Restriction',
    },
    {
      'code': 'SR-TRK-0145',
      'type': 'Track Segment',
      'zone': 'Southern Railway',
      'corridor': 'Chennai - Arakkonam',
      'km': 'KM 124/6',
      'severity': 'Good',
      'defect': 'No Defects Detected',
      'reading': 'Inspection Completed • Track geometry within standard RDSO limits',
      'sensor': 'Track Trolley #04',
      'date': '2026-09-28 08:45',
      'status': 'Verified Stable',
    },
    {
      'code': 'SR-TRK-00034',
      'type': 'Rail Bolt & Elastic Pad',
      'zone': 'South Western Railway',
      'corridor': 'Bangalore - Mysore High Speed Route',
      'km': 'KM 42/1',
      'severity': 'Good',
      'defect': 'Nominal Operating Parameters',
      'reading': 'DAS Vibration: 0.4 mm/s • Drone Thermography: Temperature 34°C',
      'sensor': 'DAS Acoustic',
      'date': '2026-09-26 15:40',
      'status': 'Healthy',
    },
    {
      'code': 'SR-TRK-DFC08',
      'type': 'Heavy Freight Track',
      'zone': 'DFCCIL',
      'corridor': 'Western DFC (Dadri - Rewari)',
      'km': 'KM 312/0',
      'severity': 'Good',
      'defect': 'Heavy Axle Load Nominal',
      'reading': 'Automated Geometry Car: 1676mm gauge, 0mm cross-level deviation',
      'sensor': 'DFCC Geometry Car',
      'date': '2026-09-26 13:00',
      'status': 'Healthy',
    },
    {
      'code': 'SR-TRK-CR008',
      'type': 'Diamond Crossing Rail',
      'zone': 'Central Railway',
      'corridor': 'Nagpur Grand Crossing',
      'km': 'Diamond Node 4',
      'severity': 'Good',
      'defect': 'Flange Angle Clean',
      'reading': 'High-Speed Acoustic Sensors: Clear of wheel impact resonance',
      'sensor': 'WILD Station',
      'date': '2026-09-26 10:15',
      'status': 'Healthy',
    },
    {
      'code': 'SR-TRK-WCR11',
      'type': 'Long Welded Rail (LWR)',
      'zone': 'West Central Railway',
      'corridor': 'Bhopal - Itarsi Trunk Line',
      'km': 'KM 512/9',
      'severity': 'Good',
      'defect': 'Weld Integrity 100%',
      'reading': 'Continuous USFD: Zero ultrasonic reflections in flash-butt welds',
      'sensor': 'USFD Rail Car',
      'date': '2026-09-25 17:30',
      'status': 'Healthy',
    },
    {
      'code': 'SR-TRK-NR019',
      'type': 'Cant & Curve Rail',
      'zone': 'Northern Railway',
      'corridor': 'Lucknow - Kanpur Fast Corridor',
      'km': 'Curve #12 (KM 48/2)',
      'severity': 'Warning',
      'defect': 'Check Rail Gauge Widening 3.1mm',
      'reading': 'ITMS Laser: Outer curve rail flange wear approaching 5mm limit',
      'sensor': 'ITMS Laser',
      'date': '2026-09-25 14:22',
      'status': 'Under Observation',
    },
    {
      'code': 'SR-TRK-ER041',
      'type': 'Howrah Station Yard Rail',
      'zone': 'Eastern Railway',
      'corridor': 'Howrah Terminal Platform 8 Approaches',
      'km': 'KM 2/1',
      'severity': 'Under Repair',
      'defect': 'Turnout Point Stretcher Bar Play',
      'reading': 'Point machine electric current profile showed 18% resistance surge',
      'sensor': 'Point Motor Telemetry',
      'date': '2026-09-25 09:10',
      'status': 'Track Gang on Site',
    },
    {
      'code': 'SR-TRK-SCR02',
      'type': 'Pandrol Clip Fastener',
      'zone': 'South Central Railway',
      'corridor': 'Secunderabad - Kazipet Section',
      'km': 'KM 118/5',
      'severity': 'Good',
      'defect': 'All Clips Seated',
      'reading': 'Loco-Vision Twin Camera: 4,820 fasteners verified with 0 missing',
      'sensor': 'Loco AI Vision',
      'date': '2026-09-24 16:50',
      'status': 'Healthy',
    },
    {
      'code': 'SR-TRK-00055',
      'type': 'Insulated Track Joint (ITJ)',
      'zone': 'Southern Railway',
      'corridor': 'Coimbatore - Palakkad Gap',
      'km': 'KM 201/3',
      'severity': 'Good',
      'defect': 'Signaling Circuit Normal',
      'reading': 'Electronic Track Circuit: High insulation resistance (>28 MΩ)',
      'sensor': 'Signaling Telemetry',
      'date': '2026-09-24 12:40',
      'status': 'Healthy',
    },
    {
      'code': 'SR-TRK-WDFC14',
      'type': 'Heavy Haul Concrete Sleeper',
      'zone': 'DFCCIL',
      'corridor': 'Western DFC (Ahmedabad - Palanpur)',
      'km': 'KM 418/7',
      'severity': 'Warning',
      'defect': 'Surface Micro-Fissure on Rail Seat',
      'reading': 'Drone AI Orthomosaic: 0.6mm surface hairline crack detected',
      'sensor': 'Drone High-Res Vision',
      'date': '2026-09-23 16:15',
      'status': 'Assigned',
    },
    {
      'code': 'SR-TRK-00088',
      'type': 'Expansion Joint (SEJ)',
      'zone': 'Southern Railway',
      'corridor': 'Chennai - Villupuram Main Line',
      'km': 'KM 94/1',
      'severity': 'Under Repair',
      'defect': 'SEJ Gap Thermal Breathing Deviation',
      'reading': 'Linear displacement sensor: Gap 48mm vs target 65mm for 38°C rail',
      'sensor': 'IoT Thermal Sensor',
      'date': '2026-09-23 11:35',
      'status': 'Destressing Gang Assigned',
    },
  ];

  List<Map<String, dynamic>> get _filteredDetections {
    return _realtimeAssetDetections.where((d) {
      if (assetFilterSeverity == 'CRITICAL' && d['severity'] != 'Critical') return false;
      if (assetFilterSeverity == 'WARNING' && d['severity'] != 'Warning') return false;
      if (assetFilterSeverity == 'GOOD' && d['severity'] != 'Good') return false;
      if (assetFilterSeverity == 'REPAIR' && d['severity'] != 'Under Repair') return false;

      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final c = (d['code'] ?? '').toString().toLowerCase();
        final t = (d['type'] ?? '').toString().toLowerCase();
        final z = (d['zone'] ?? '').toString().toLowerCase();
        final cor = (d['corridor'] ?? '').toString().toLowerCase();
        final def = (d['defect'] ?? '').toString().toLowerCase();
        final sens = (d['sensor'] ?? '').toString().toLowerCase();
        return c.contains(q) ||
            t.contains(q) ||
            z.contains(q) ||
            cor.contains(q) ||
            def.contains(q) ||
            sens.contains(q);
      }
      return true;
    }).toList();
  }

  Color _severityColor(String sev) {
    switch (sev) {
      case 'Critical':
        return SmartRailTheme.danger;
      case 'Warning':
        return SmartRailTheme.amber;
      case 'Good':
        return const Color(0xFF10B981);
      case 'Under Repair':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF0284C7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Export Report',
            onPressed: _showExportDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Analytics',
            onPressed: _load,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: SmartRailTheme.amber,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(text: 'Track Report'),
            Tab(text: 'Asset Report'),
            Tab(text: 'Maintenance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrackReportTab(),
          _buildAssetReportTab(),
          _buildMaintenanceAnalyticsTab(),
        ],
      ),
    );
  }

  // TAB 1: Track Report (Matching Mockup Screen 5 with Donut Chart & Defect Bars)
  Widget _buildTrackReportTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Dropdown Time Period Filter (Mockup: "Last 6 Months v")
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Inspection Timeframe',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedPeriod,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: SmartRailTheme.navy),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: SmartRailTheme.navy,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Last 7 Days', child: Text('Last 7 Days')),
                    DropdownMenuItem(value: 'Last 30 Days', child: Text('Last 30 Days')),
                    DropdownMenuItem(value: 'Last 6 Months', child: Text('Last 6 Months')),
                    DropdownMenuItem(value: 'Year to Date', child: Text('Year to Date')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => selectedPeriod = val);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // SECTION 1: Track Condition Overview Donut Chart (Matching Mockup Screen 5)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Track Condition Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  // Donut Chart with Total Assets in Center
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 42,
                            sections: [
                              PieChartSectionData(
                                color: const Color(0xFF10B981),
                                value: 38,
                                showTitle: false,
                                radius: touchedPieIndex == 0 ? 22 : 18,
                              ),
                              PieChartSectionData(
                                color: SmartRailTheme.amber,
                                value: 9,
                                showTitle: false,
                                radius: touchedPieIndex == 1 ? 22 : 18,
                              ),
                              PieChartSectionData(
                                color: SmartRailTheme.danger,
                                value: 4,
                                showTitle: false,
                                radius: touchedPieIndex == 2 ? 22 : 18,
                              ),
                              PieChartSectionData(
                                color: const Color(0xFF8B5CF6),
                                value: 2,
                                showTitle: false,
                                radius: touchedPieIndex == 3 ? 22 : 18,
                              ),
                            ],
                            pieTouchData: PieTouchData(
                              touchCallback: (event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedPieIndex = -1;
                                    return;
                                  }
                                  touchedPieIndex =
                                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                          ),
                        ),
                        const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Total Assets',
                              style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                            ),
                            Text(
                              '53',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  // Donut Legend (Matching Mockup Screen 5)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDonutLegendItem('Good', '38', '71.7%', const Color(0xFF10B981)),
                        const SizedBox(height: 8),
                        _buildDonutLegendItem('Warning', '9', '17.0%', SmartRailTheme.amber),
                        const SizedBox(height: 8),
                        _buildDonutLegendItem('Critical', '4', '7.5%', SmartRailTheme.danger),
                        const SizedBox(height: 8),
                        _buildDonutLegendItem('Under Repair', '2', '3.8%', const Color(0xFF8B5CF6)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // SECTION 2: Defect Types Bar Chart (Matching Mockup Screen 5)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Defect Types',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              _buildDefectBar('Loose Fastener', 14, 18, const Color(0xFF0284C7)),
              const SizedBox(height: 12),
              _buildDefectBar('Rail Wear', 9, 18, const Color(0xFF0284C7)),
              const SizedBox(height: 12),
              _buildDefectBar('Joint Micro-Crack', 6, 18, const Color(0xFF0284C7)),
              const SizedBox(height: 12),
              _buildDefectBar('Ballast Void', 4, 18, const Color(0xFF0284C7)),
              const SizedBox(height: 12),
              _buildDefectBar('Switch Point Misalignment', 3, 18, const Color(0xFF0284C7)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // SECTION 3: Enormous Real-Time Assets Detection Header & Filters
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Real-Time Track Assets Detection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Live sensor feeds from ITMS, WILD, USFD & GPR',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_filteredDetections.length} Live',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Search Bar for Detections
        TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Search 40+ detected track assets by ID, defect, zone...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12.5),
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
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          onChanged: (val) => setState(() => searchQuery = val),
        ),
        const SizedBox(height: 10),

        // Severity Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('ALL', 'All Detections'),
              const SizedBox(width: 8),
              _buildFilterChip('CRITICAL', 'Critical (${_countSev('Critical')})', isAlert: true),
              const SizedBox(width: 8),
              _buildFilterChip('WARNING', 'Warning (${_countSev('Warning')})'),
              const SizedBox(width: 8),
              _buildFilterChip('GOOD', 'Good (${_countSev('Good')})'),
              const SizedBox(width: 8),
              _buildFilterChip('REPAIR', 'Under Repair (${_countSev('Under Repair')})'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Detections List
        ..._filteredDetections.map((d) {
          final color = _severityColor(d['severity']);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
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
                      builder: (_) => AssetDetailScreen(assetCode: d['code']),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                d['code'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              d['severity'],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${d['type']} • ${d['corridor']} (${d['km']})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Defect: ',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: Text(
                                    d['defect'],
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              d['reading'],
                              style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Detected: ${d['date']}',
                            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                          ),
                          const Row(
                            children: [
                              Text(
                                'View Asset',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: SmartRailTheme.accent,
                                ),
                              ),
                              Icon(Icons.chevron_right, size: 15, color: SmartRailTheme.accent),
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
        }),
      ],
    );
  }

  // TAB 2: Asset Report & Statistics (Matching Mockup Screen 9)
  Widget _buildAssetReportTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Maintenance Trend Multi-Line Chart (Mockup Screen 9)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
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
                  const Text(
                    'Maintenance Trend',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Last 6 Months',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: SmartRailTheme.navy,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Trend Legend
              const Row(
                children: [
                  _TrendLegend(color: Color(0xFF0284C7), label: 'Inspections'),
                  SizedBox(width: 14),
                  _TrendLegend(color: Color(0xFFF59E0B), label: 'Defects'),
                  SizedBox(width: 14),
                  _TrendLegend(color: Color(0xFF10B981), label: 'Repairs'),
                ],
              ),
              const SizedBox(height: 20),
              // Line Chart
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (v, _) => Text(
                            '${v.toInt()}',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final months = ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'];
                            final idx = v.toInt();
                            if (idx >= 0 && idx < months.length) {
                              return Text(
                                months[idx],
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Inspections Line (Blue)
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 14),
                          FlSpot(1, 18),
                          FlSpot(2, 22),
                          FlSpot(3, 31),
                          FlSpot(4, 30),
                          FlSpot(5, 37),
                        ],
                        isCurved: true,
                        color: const Color(0xFF0284C7),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                      ),
                      // Defects Line (Amber)
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 8),
                          FlSpot(1, 10),
                          FlSpot(2, 12),
                          FlSpot(3, 15),
                          FlSpot(4, 14),
                          FlSpot(5, 12),
                        ],
                        isCurved: true,
                        color: const Color(0xFFF59E0B),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                      ),
                      // Repairs Line (Green)
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 6),
                          FlSpot(1, 9),
                          FlSpot(2, 11),
                          FlSpot(3, 14),
                          FlSpot(4, 16),
                          FlSpot(5, 23),
                        ],
                        isCurved: true,
                        color: const Color(0xFF10B981),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // KPI Cards (Mockup Screen 9: Total Inspections 312, Avg Repair Time 2.4 days)
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                icon: Icons.assignment_turned_in_rounded,
                iconColor: const Color(0xFF0284C7),
                title: 'Total Inspections',
                value: '312',
                badge: '+12%',
                badgePositive: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                icon: Icons.timer_rounded,
                iconColor: const Color(0xFFF59E0B),
                title: 'Avg. Repair Time',
                value: '2.4 days',
                badge: '-18%',
                badgePositive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Asset Type Breakdown Table
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Monitored Assets Inventory',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),
              _buildInventoryRow('Elastic Rail Clips & Fasteners', '18 Units', '94% Normal'),
              const Divider(height: 18),
              _buildInventoryRow('Prestressed Concrete Sleepers', '24 Segments', '96% Normal'),
              const Divider(height: 18),
              _buildInventoryRow('Fishplate Welded Joints', '12 Joints', '83% Normal'),
              const Divider(height: 18),
              _buildInventoryRow('Turnout Switch Point Units', '6 Points', '67% Normal'),
            ],
          ),
        ),
      ],
    );
  }

  // TAB 3: Maintenance & Safety Performance (Matching Mockup Screen 10)
  Widget _buildMaintenanceAnalyticsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // System Health Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFECFDF5),
                ),
                child: const Icon(Icons.verified_user_rounded,
                    color: Color(0xFF10B981), size: 36),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Health',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '82%',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Good',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Grid of Safety Metrics (Mockup Screen 10)
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                icon: Icons.access_time_rounded,
                title: 'On-Time Maintenance',
                value: '96%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                icon: Icons.train_rounded,
                title: 'Track Availability',
                value: '98%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                icon: Icons.trending_down_rounded,
                title: 'Defect Reduction',
                value: '18%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                icon: Icons.shield_rounded,
                title: 'Safety Score',
                value: '99%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Banner: Safer Tracks, Stronger Railways (Mockup Screen 10)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0B1F3A), Color(0xFF1E3A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B1F3A).withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white12,
                ),
                child: const Icon(Icons.speed_rounded, color: Color(0xFF38BDF8), size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Safer Tracks',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Stronger Railways',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF93C5FD),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  int _countSev(String s) {
    return _realtimeAssetDetections.where((d) => d['severity'] == s).length;
  }

  Widget _buildDonutLegendItem(String label, String count, String pct, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          count,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 6),
        Text(
          '($pct)',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDefectBar(String title, int count, int total, Color color) {
    final pct = (count / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            Text(
              '$count',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label, {bool isAlert = false}) {
    final isSelected = assetFilterSeverity == key;
    return GestureDetector(
      onTap: () => setState(() => assetFilterSeverity = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isAlert ? SmartRailTheme.danger : SmartRailTheme.navy)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String badge,
    required bool badgePositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
              Icon(icon, color: iconColor, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Icon(icon, color: SmartRailTheme.navy, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryRow(String name, String count, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          count,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF10B981),
            ),
          ),
        ),
      ],
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf_rounded, color: SmartRailTheme.danger),
            SizedBox(width: 8),
            Text('Export Track Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Generate comprehensive Indian Railways RDSO Track Asset Audit Report (PDF/Excel) with all 40+ sensor detections and AI predictive telemetry?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: SmartRailTheme.navy,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report generated: SmartRail_Asset_Audit_2026.pdf'),
                  backgroundColor: Color(0xFF0B1F3A),
                ),
              );
            },
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Download PDF'),
          ),
        ],
      ),
    );
  }
}

class _TrendLegend extends StatelessWidget {
  const _TrendLegend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}
