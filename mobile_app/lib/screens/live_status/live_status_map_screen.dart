import 'package:flutter/material.dart';
import 'package:smart_rail/screens/assets/asset_detail_screen.dart';
import 'package:smart_rail/utils/theme.dart';

class LiveStatusMapScreen extends StatefulWidget {
  const LiveStatusMapScreen({super.key});

  @override
  State<LiveStatusMapScreen> createState() => _LiveStatusMapScreenState();
}

class _LiveStatusMapScreenState extends State<LiveStatusMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String selectedFilter = 'ALL'; // ALL, GOOD, WARNING, CRITICAL
  String activeSensorMode = 'ALL'; // ALL, ITMS, GPR, USFD, WILD, DAS, DRONE
  String selectedZone = 'ALL';
  _StationNode? selectedStation;

  final List<_StationNode> stations = [
    _StationNode(
      id: 'NDLS',
      name: 'New Delhi (NDLS)',
      zone: 'Northern Railway',
      x: 0.38,
      y: 0.26,
      status: 'NORMAL',
      healthPercent: 96,
      assetCode: 'SR-TRK-NDLS01',
      speedLimit: '160 km/h (Vande Bharat)',
      sensorData: 'ITMS: 0.2mm geometry deviation • USFD: 0 defects • WILD: 135 kN',
    ),
    _StationNode(
      id: 'CSMT',
      name: 'Mumbai Central (CSMT)',
      zone: 'Western / Central',
      x: 0.26,
      y: 0.58,
      status: 'WARNING',
      healthPercent: 82,
      assetCode: 'SR-TRK-WR009',
      speedLimit: '110 km/h (PSR active)',
      sensorData: 'WILD: Peak 210 kN dynamic impact • Ballast settling detected by GPR',
    ),
    _StationNode(
      id: 'MAS',
      name: 'Chennai Central (MAS)',
      zone: 'Southern Railway',
      x: 0.48,
      y: 0.78,
      status: 'CRITICAL',
      healthPercent: 68,
      assetCode: 'SR-TRK-00145',
      speedLimit: '45 km/h (Caution Order)',
      sensorData: 'USFD: Internal crack warning at KM 124/6 • DAS: 42Hz acoustic anomaly',
    ),
    _StationNode(
      id: 'HWH',
      name: 'Kolkata Howrah (HWH)',
      zone: 'Eastern Railway',
      x: 0.72,
      y: 0.48,
      status: 'NORMAL',
      healthPercent: 94,
      assetCode: 'SR-TRK-ER041',
      speedLimit: '130 km/h',
      sensorData: 'ITMS: Clear • USFD: 100% verified weld joints • GPR: Dry ballast',
    ),
    _StationNode(
      id: 'SBC',
      name: 'Bengaluru (SBC)',
      zone: 'South Western Railway',
      x: 0.42,
      y: 0.79,
      status: 'NORMAL',
      healthPercent: 92,
      assetCode: 'SR-TRK-00034',
      speedLimit: '130 km/h',
      sensorData: 'DAS-AI: Nominal vibration 0.4 mm/s • Drone thermography: Optimal',
    ),
    _StationNode(
      id: 'SC',
      name: 'Hyderabad / Secunderabad',
      zone: 'South Central Railway',
      x: 0.44,
      y: 0.61,
      status: 'NORMAL',
      healthPercent: 95,
      assetCode: 'SR-TRK-SCR02',
      speedLimit: '140 km/h',
      sensorData: 'Loco-Vision Twin: 100% Pandrol clips verified',
    ),
    _StationNode(
      id: 'ADI',
      name: 'Ahmedabad (ADI)',
      zone: 'Western Railway',
      x: 0.22,
      y: 0.44,
      status: 'NORMAL',
      healthPercent: 98,
      assetCode: 'SR-TRK-WR015',
      speedLimit: '130 km/h',
      sensorData: 'WDFC Corridor: Heavy axle load 32.5T cleared • USFD ok',
    ),
    _StationNode(
      id: 'LKO',
      name: 'Lucknow (LKO)',
      zone: 'Northern Railway',
      x: 0.52,
      y: 0.32,
      status: 'NORMAL',
      healthPercent: 90,
      assetCode: 'SR-TRK-NR019',
      speedLimit: '130 km/h',
      sensorData: 'ITMS: Laser track gauge 1676mm nominal',
    ),
    _StationNode(
      id: 'PNBE',
      name: 'Patna (PNBE)',
      zone: 'East Central Railway',
      x: 0.64,
      y: 0.36,
      status: 'WARNING',
      healthPercent: 79,
      assetCode: 'SR-TRK-ECR07',
      speedLimit: '100 km/h',
      sensorData: 'GPR: Moisture ingress detected in sub-ballast layer',
    ),
    _StationNode(
      id: 'BPL',
      name: 'Bhopal (BPL)',
      zone: 'West Central Railway',
      x: 0.40,
      y: 0.46,
      status: 'NORMAL',
      healthPercent: 93,
      assetCode: 'SR-TRK-WCR11',
      speedLimit: '130 km/h',
      sensorData: 'DAS: Real-time train tracking without track circuits',
    ),
    _StationNode(
      id: 'NGP',
      name: 'Nagpur (NGP)',
      zone: 'Central Railway',
      x: 0.45,
      y: 0.52,
      status: 'NORMAL',
      healthPercent: 91,
      assetCode: 'SR-TRK-CR008',
      speedLimit: '130 km/h',
      sensorData: 'Diamond Crossing sensor telemetry active',
    ),
    _StationNode(
      id: 'GHY',
      name: 'Guwahati (GHY)',
      zone: 'Northeast Frontier',
      x: 0.88,
      y: 0.32,
      status: 'WARNING',
      healthPercent: 81,
      assetCode: 'SR-TRK-NFR01',
      speedLimit: '100 km/h',
      sensorData: 'Satellite InSAR: Slope monitoring on hill section',
    ),
    _StationNode(
      id: 'MDU',
      name: 'Madurai (MDU)',
      zone: 'Southern Railway',
      x: 0.46,
      y: 0.89,
      status: 'NORMAL',
      healthPercent: 94,
      assetCode: 'SR-TRK-00048',
      speedLimit: '110 km/h',
      sensorData: 'PSC Sleeper integrity: 100% verified',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071224),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071224),
        title: const Row(
          children: [
            Icon(Icons.radar, color: Color(0xFF10B981), size: 22),
            SizedBox(width: 8),
            Text(
              'LIVE RAILWAY MAP OF INDIA',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fiber_manual_record, color: Color(0xFF10B981), size: 10),
                SizedBox(width: 4),
                Text(
                  'LIVE AI FEED',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips (Health & Sensors)
          _buildControlBar(),
          // Main Interactive Vector Map Canvas
          Expanded(
            child: Stack(
              children: [
                // Glowing Background Grid & Outline
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _animController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _IndiaRailwayMapPainter(
                          stations: stations,
                          selectedFilter: selectedFilter,
                          activeSensorMode: activeSensorMode,
                          animationValue: _animController.value,
                          selectedStation: selectedStation,
                        ),
                      );
                    },
                  ),
                ),
                // Tap detection targets for station nodes
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          for (final st in stations)
                            if (_matchesFilter(st))
                              Positioned(
                                left: constraints.maxWidth * st.x - 18,
                                top: constraints.maxHeight * st.y - 18,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => selectedStation = st);
                                    _showStationDetailSheet(st);
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                        ],
                      );
                    },
                  ),
                ),
                // Floating Legend & Real-Time Stats
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildMapLegend(),
                ),
                Positioned(
                  bottom: 14,
                  right: 14,
                  left: 14,
                  child: _buildLiveCorridorBanner(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesFilter(_StationNode st) {
    if (selectedFilter == 'GOOD' && st.status != 'NORMAL') return false;
    if (selectedFilter == 'WARNING' && st.status != 'WARNING') return false;
    if (selectedFilter == 'CRITICAL' && st.status != 'CRITICAL') return false;
    return true;
  }

  Widget _buildControlBar() {
    return Container(
      color: const Color(0xFF0F1E36),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          // Health Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'HEALTH: ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                _statusChip('ALL TRACKS', selectedFilter == 'ALL', const Color(0xFF38BDF8), () {
                  setState(() => selectedFilter = 'ALL');
                }),
                const SizedBox(width: 6),
                _statusChip('GOOD (SAFE)', selectedFilter == 'GOOD', const Color(0xFF10B981), () {
                  setState(() => selectedFilter = 'GOOD');
                }),
                const SizedBox(width: 6),
                _statusChip('WARNING', selectedFilter == 'WARNING', const Color(0xFFF59E0B), () {
                  setState(() => selectedFilter = 'WARNING');
                }),
                const SizedBox(width: 6),
                _statusChip('CRITICAL (ALERT)', selectedFilter == 'CRITICAL', const Color(0xFFEF4444), () {
                  setState(() => selectedFilter = 'CRITICAL');
                }),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Innovative Systems Sensor Mode
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'SENSORS: ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                _sensorChip('ALL SENSORS', activeSensorMode == 'ALL'),
                _sensorChip('ITMS LASER', activeSensorMode == 'ITMS'),
                _sensorChip('USFD FLAW', activeSensorMode == 'USFD'),
                _sensorChip('WILD IMPACT', activeSensorMode == 'WILD'),
                _sensorChip('GPR BALLAST', activeSensorMode == 'GPR'),
                _sensorChip('DAS ACOUSTIC', activeSensorMode == 'DAS'),
                _sensorChip('DRONE LiDAR', activeSensorMode == 'DRONE'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, bool active, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.25) : Colors.black26,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? color : Colors.white24, width: 1.2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }

  Widget _sensorChip(String label, bool active) {
    return GestureDetector(
      onTap: () {
        final mode = label.split(' ').first;
        setState(() => activeSensorMode = mode == 'ALL' ? 'ALL' : mode);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF97316).withValues(alpha: 0.25) : Colors.black12,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? const Color(0xFFF97316) : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? const Color(0xFFFDBA74) : Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _buildMapLegend() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _legendItem(const Color(0xFF10B981), 'Good Track (Safe 130-160 km/h)'),
          const SizedBox(height: 4),
          _legendItem(const Color(0xFFF59E0B), 'Warning (Wear / Maintenance Watch)'),
          const SizedBox(height: 4),
          _legendItem(const Color(0xFFEF4444), 'Critical Alert (Urgent Repair)'),
          const SizedBox(height: 4),
          _legendItem(const Color(0xFF38BDF8), 'Golden Quad. / DFC Corridor'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 9.5, color: Colors.white70)),
      ],
    );
  }

  Widget _buildLiveCorridorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SmartRailTheme.danger.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
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
                builder: (_) => const AssetDetailScreen(assetCode: 'IR-TRACK-102'),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SmartRailTheme.danger.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded, color: SmartRailTheme.danger, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'IR-TRACK-102',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Chennai - Central → New Delhi',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Speed: 142 km/h  |  Geometry: 99.4%',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF38BDF8), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: SmartRailTheme.danger,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ALERT >',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStationDetailSheet(_StationNode st) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B192E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final isCritical = st.status == 'CRITICAL';
        final isWarning = st.status == 'WARNING';
        final statusColor = isCritical
            ? SmartRailTheme.danger
            : (isWarning ? SmartRailTheme.amber : SmartRailTheme.ok);

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      st.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      st.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Zone: ${st.zone} | Asset Code: ${st.assetCode}',
                style: const TextStyle(fontSize: 12.5, color: Colors.white70),
              ),
              const Divider(color: Colors.white24, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sheetStat('Track Health', '${st.healthPercent}%', statusColor),
                  _sheetStat('Speed Limit', st.speedLimit, Colors.white),
                  _sheetStat('Signal Corridor', 'Automatic Block', const Color(0xFF38BDF8)),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.sensors, size: 16, color: Color(0xFF38BDF8)),
                        SizedBox(width: 6),
                        Text(
                          'Innovative Sensor Telemetry',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      st.sensorData,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor,
                        minimumSize: const Size(0, 44),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AssetDetailScreen(assetCode: st.assetCode),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('INSPECT ASSET DETAILS'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sheetStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class _StationNode {
  _StationNode({
    required this.id,
    required this.name,
    required this.zone,
    required this.x,
    required this.y,
    required this.status,
    required this.healthPercent,
    required this.assetCode,
    required this.speedLimit,
    required this.sensorData,
  });

  final String id;
  final String name;
  final String zone;
  final double x;
  final double y;
  final String status;
  final int healthPercent;
  final String assetCode;
  final String speedLimit;
  final String sensorData;
}

class _IndiaRailwayMapPainter extends CustomPainter {
  _IndiaRailwayMapPainter({
    required this.stations,
    required this.selectedFilter,
    required this.activeSensorMode,
    required this.animationValue,
    this.selectedStation,
  });

  final List<_StationNode> stations;
  final String selectedFilter;
  final String activeSensorMode;
  final double animationValue;
  final _StationNode? selectedStation;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw subtle geographical outline of India
    _drawIndiaBoundary(canvas, size);

    // 2. Draw Major Railway Corridors (Golden Quadrilateral & DFC)
    _drawRailwayCorridors(canvas, size);

    // 3. Draw Moving Inspection Train along the track
    _drawMovingInspectionTrain(canvas, size);

    // 4. Draw Station Nodes & Asset Pins
    _drawStationNodes(canvas, size);
  }

  void _drawIndiaBoundary(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final boundaryPaint = Paint()
      ..color = const Color(0xFF1E3A8A).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = const Color(0xFF0C1B33).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Simplified polygon of India coastline and borders
    final path = Path();
    path.moveTo(w * 0.35, h * 0.10); // Kashmir north
    path.lineTo(w * 0.44, h * 0.12); // Ladakh
    path.lineTo(w * 0.50, h * 0.22); // Himachal/Uttarakhand
    path.lineTo(w * 0.62, h * 0.28); // Nepal border
    path.lineTo(w * 0.70, h * 0.27); // Sikkim
    path.lineTo(w * 0.88, h * 0.26); // Assam/Arunachal
    path.lineTo(w * 0.92, h * 0.34); // Nagaland/Manipur
    path.lineTo(w * 0.82, h * 0.40); // Tripura/Meghalaya
    path.lineTo(w * 0.74, h * 0.44); // Bengal delta
    path.lineTo(w * 0.68, h * 0.54); // Odisha coast
    path.lineTo(w * 0.58, h * 0.68); // Andhra coast
    path.lineTo(w * 0.48, h * 0.80); // Tamil Nadu coast
    path.lineTo(w * 0.44, h * 0.94); // Kanyakumari south tip
    path.lineTo(w * 0.38, h * 0.84); // Kerala coast
    path.lineTo(w * 0.32, h * 0.72); // Karnataka/Goa
    path.lineTo(w * 0.25, h * 0.60); // Mumbai/Konkan
    path.lineTo(w * 0.18, h * 0.48); // Gujarat coast / Kathiawar
    path.lineTo(w * 0.14, h * 0.42); // Kutch
    path.lineTo(w * 0.26, h * 0.30); // Rajasthan border
    path.lineTo(w * 0.30, h * 0.18); // Punjab border
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, boundaryPaint);
  }

  void _drawRailwayCorridors(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Helper map of station coordinates
    Map<String, Offset> pos = {};
    for (final s in stations) {
      pos[s.id] = Offset(w * s.x, h * s.y);
    }

    final corridorTrack = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final criticalTrack = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final warningTrack = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Connections (Golden Quadrilateral & Diagonals)
    void drawSegment(String a, String b, {Paint? customPaint}) {
      if (pos.containsKey(a) && pos.containsKey(b)) {
        canvas.drawLine(pos[a]!, pos[b]!, customPaint ?? corridorTrack);
      }
    }

    // Golden Quadrilateral:
    drawSegment('NDLS', 'CSMT'); // Delhi - Mumbai
    drawSegment('CSMT', 'MAS'); // Mumbai - Chennai
    drawSegment('MAS', 'HWH'); // Chennai - Kolkata
    drawSegment('HWH', 'NDLS'); // Kolkata - Delhi

    // Diagonals & Spine:
    drawSegment('NDLS', 'BPL'); // Delhi - Bhopal
    drawSegment('BPL', 'NGP'); // Bhopal - Nagpur
    drawSegment('NGP', 'SC'); // Nagpur - Secunderabad
    drawSegment('SC', 'MAS'); // Secunderabad - Chennai
    drawSegment('SC', 'SBC'); // Secunderabad - Bengaluru
    drawSegment('SBC', 'MAS', customPaint: criticalTrack); // Critical monitored track SR-TRK-00145
    drawSegment('MAS', 'MDU'); // Chennai - Madurai
    drawSegment('CSMT', 'ADI'); // Mumbai - Ahmedabad
    drawSegment('ADI', 'NDLS'); // Ahmedabad - Delhi
    drawSegment('NDLS', 'LKO'); // Delhi - Lucknow
    drawSegment('LKO', 'PNBE'); // Lucknow - Patna
    drawSegment('PNBE', 'HWH'); // Patna - Howrah
    drawSegment('HWH', 'GHY', customPaint: warningTrack); // Howrah - Guwahati
  }

  void _drawMovingInspectionTrain(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Animate train along Delhi -> Bhopal -> Nagpur -> Secunderabad -> Chennai
    final waypoints = [
      Offset(w * 0.38, h * 0.26), // NDLS
      Offset(w * 0.40, h * 0.46), // BPL
      Offset(w * 0.45, h * 0.52), // NGP
      Offset(w * 0.44, h * 0.61), // SC
      Offset(w * 0.48, h * 0.78), // MAS
    ];

    final totalSegments = waypoints.length - 1;
    final progress = animationValue * totalSegments;
    final segIdx = progress.floor().clamp(0, totalSegments - 1);
    final segT = progress - segIdx;

    final trainPos = Offset.lerp(waypoints[segIdx], waypoints[segIdx + 1], segT)!;

    // Glowing Radar Pulse around moving train
    final pulsePaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.3 * (1 - segT))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(trainPos, 14 + (segT * 10), pulsePaint);

    final trainPaint = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(trainPos, 6, trainPaint);

    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(trainPos, 2.5, innerPaint);
  }

  void _drawStationNodes(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (final st in stations) {
      final pos = Offset(w * st.x, h * st.y);
      final isSelected = selectedStation?.id == st.id;

      Color nodeColor = const Color(0xFF10B981); // Normal
      if (st.status == 'CRITICAL') {
        nodeColor = const Color(0xFFEF4444);
      } else if (st.status == 'WARNING') {
        nodeColor = const Color(0xFFF59E0B);
      }

      // Outer Glow
      if (st.status == 'CRITICAL' || isSelected) {
        final glow = Paint()
          ..color = nodeColor.withValues(alpha: 0.4)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, isSelected ? 16 : 12, glow);
      }

      // Main Node Circle
      final nodePaint = Paint()
        ..color = nodeColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, isSelected ? 7 : 5, nodePaint);

      // Inner White Center
      final centerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 2, centerPaint);

      // Node Label
      final textSpan = TextSpan(
        text: st.id,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 8.5,
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(pos.dx + 7, pos.dy - 5));
    }
  }

  @override
  bool shouldRepaint(covariant _IndiaRailwayMapPainter oldDelegate) => true;
}
