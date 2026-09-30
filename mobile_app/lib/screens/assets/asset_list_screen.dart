import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_rail/screens/assets/asset_detail_screen.dart';
import 'package:smart_rail/screens/assets/asset_form_screen.dart';
import 'package:smart_rail/screens/inspection/inspection_screen.dart';
import 'package:smart_rail/services/session.dart';
import 'package:smart_rail/utils/theme.dart';

class AssetListScreen extends StatefulWidget {
  const AssetListScreen({super.key});

  @override
  State<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends State<AssetListScreen> {
  List<Map<String, dynamic>> assets = [];
  bool loading = true;
  String selectedFilter = 'ALL'; // ALL, GOOD, WARNING, CRITICAL, FASTENER, TRACK, JOINT, SWITCH
  String searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final data = await context.read<SessionController>().api.get('/api/assets');
      if (data is List && data.isNotEmpty) {
        setState(() {
          assets = List<Map<String, dynamic>>.from(
            data.map((e) => Map<String, dynamic>.from(e as Map)),
          );
          loading = false;
        });
        return;
      }
    } catch (_) {}

    // Rich offline fallback assets with complete track photos and metadata
    setState(() {
      assets = _buildDefaultAssets();
      loading = false;
    });
  }

  List<Map<String, dynamic>> _buildDefaultAssets() {
    return [
      {
        'id': 1,
        'asset_code': 'SR-TRK-00145',
        'asset_type': 'Rail Fastener / Clip',
        'location': 'KM 124/6 (Chennai-Arakkonam)',
        'railway_zone': 'Southern Railway',
        'condition': 'Poor',
        'ai_risk_score': 78.4,
        'ai_risk_level': 'HIGH',
        'last_inspection': '2026-09-28',
        'photo': 'assets/images/rail_fastener.jpg',
        'speed_limit': '45 km/h',
        'sensor': 'ITMS + WILD: 210 kN impact',
      },
      {
        'id': 2,
        'asset_code': 'IR-TRACK-102',
        'asset_type': 'Broad Gauge Rail Track',
        'location': 'KM 142/4 (Chennai-New Delhi)',
        'railway_zone': 'Northern Railway',
        'condition': 'Critical',
        'ai_risk_score': 88.0,
        'ai_risk_level': 'CRITICAL',
        'last_inspection': '2026-09-28',
        'photo': 'assets/images/rail_track.jpg',
        'speed_limit': '142 km/h',
        'sensor': 'ITMS Laser: 3.4mm corrugation',
      },
      {
        'id': 3,
        'asset_code': 'SR-TRK-00048',
        'asset_type': 'Concrete Sleeper & Rail',
        'location': 'KM 12/4 (Madurai-Dindigul)',
        'railway_zone': 'Southern Railway',
        'condition': 'Moderate',
        'ai_risk_score': 48.0,
        'ai_risk_level': 'MEDIUM',
        'last_inspection': '2026-09-25',
        'photo': 'assets/images/rail_track.jpg',
        'speed_limit': '110 km/h',
        'sensor': 'GPR Radar: Ballast settlement',
      },
      {
        'id': 4,
        'asset_code': 'SR-TRK-00021',
        'asset_type': 'Fish Plate Joint',
        'location': 'KM 86/2 (Jolarpettai-Salem)',
        'railway_zone': 'Southern Railway',
        'condition': 'Moderate',
        'ai_risk_score': 54.0,
        'ai_risk_level': 'MEDIUM',
        'last_inspection': '2026-09-22',
        'photo': 'assets/images/fishplate_joint.jpg',
        'speed_limit': '100 km/h',
        'sensor': 'USFD: Surface crack 2.1mm',
      },
      {
        'id': 5,
        'asset_code': 'SR-TRK-00034',
        'asset_type': 'Rail Bolt & Elastic Pad',
        'location': 'KM 42/1 (Bangalore-Mysore)',
        'railway_zone': 'South Western Railway',
        'condition': 'Good',
        'ai_risk_score': 12.0,
        'ai_risk_level': 'LOW',
        'last_inspection': '2026-09-20',
        'photo': 'assets/images/rail_fastener.jpg',
        'speed_limit': '130 km/h',
        'sensor': 'DAS: Optimal vibration 0.4 mm/s',
      },
      {
        'id': 6,
        'asset_code': 'SR-TRK-WR009',
        'asset_type': 'Switch Point Component',
        'location': 'Point 14A (Basin Bridge Yard)',
        'railway_zone': 'Southern Railway',
        'condition': 'Critical',
        'ai_risk_score': 84.5,
        'ai_risk_level': 'CRITICAL',
        'last_inspection': '2026-09-19',
        'photo': 'assets/images/switch_point.jpg',
        'speed_limit': '30 km/h',
        'sensor': 'Switch Blade Gap 4.2mm',
      },
      {
        'id': 7,
        'asset_code': 'SR-TRK-00055',
        'asset_type': 'Insulated Track Joint',
        'location': 'KM 201/3 (Coimbatore-Palakkad)',
        'railway_zone': 'Southern Railway',
        'condition': 'Good',
        'ai_risk_score': 15.0,
        'ai_risk_level': 'LOW',
        'last_inspection': '2026-09-18',
        'photo': 'assets/images/fishplate_joint.jpg',
        'speed_limit': '120 km/h',
        'sensor': 'Insulation resistance > 25 ohms',
      },
      {
        'id': 8,
        'asset_code': 'SR-TRK-DFC08',
        'asset_type': 'Dedicated Freight Rail Track',
        'location': 'KM 312/0 (Dadri-Rewari WDFC)',
        'railway_zone': 'DFCCIL',
        'condition': 'Good',
        'ai_risk_score': 9.2,
        'ai_risk_level': 'LOW',
        'last_inspection': '2026-09-15',
        'photo': 'assets/images/rail_track.jpg',
        'speed_limit': '100 km/h (Heavy Axle 32.5T)',
        'sensor': 'Continuous Automated Geometry Car',
      },
    ];
  }

  String _getAssetPhoto(Map<String, dynamic> asset) {
    if (asset['photo'] != null && asset['photo'].toString().isNotEmpty) {
      return asset['photo'].toString();
    }
    final type = (asset['asset_type'] ?? '').toString().toLowerCase();
    if (type.contains('fastener') || type.contains('clip')) {
      return 'assets/images/rail_fastener.jpg';
    } else if (type.contains('joint') || type.contains('fishplate') || type.contains('fish plate')) {
      return 'assets/images/fishplate_joint.jpg';
    } else if (type.contains('switch') || type.contains('turnout') || type.contains('point')) {
      return 'assets/images/switch_point.jpg';
    } else {
      return 'assets/images/rail_track.jpg';
    }
  }

  List<Map<String, dynamic>> get _filteredAssets {
    return assets.where((a) {
      // Filter tab
      if (selectedFilter == 'GOOD') {
        final cond = (a['condition'] ?? '').toString().toLowerCase();
        if (!cond.contains('good') && !cond.contains('normal')) return false;
      } else if (selectedFilter == 'WARNING') {
        final cond = (a['condition'] ?? '').toString().toLowerCase();
        final risk = (a['ai_risk_level'] ?? '').toString().toUpperCase();
        if (!cond.contains('mod') && !cond.contains('warn') && risk != 'MEDIUM') return false;
      } else if (selectedFilter == 'CRITICAL') {
        final cond = (a['condition'] ?? '').toString().toLowerCase();
        final risk = (a['ai_risk_level'] ?? '').toString().toUpperCase();
        if (!cond.contains('crit') && !cond.contains('poor') && risk != 'HIGH' && risk != 'CRITICAL') {
          return false;
        }
      } else if (selectedFilter == 'FASTENER') {
        final type = (a['asset_type'] ?? '').toString().toLowerCase();
        if (!type.contains('fastener') && !type.contains('clip')) return false;
      } else if (selectedFilter == 'TRACK') {
        final type = (a['asset_type'] ?? '').toString().toLowerCase();
        if (!type.contains('track') && !type.contains('sleeper') && !type.contains('rail')) return false;
      } else if (selectedFilter == 'JOINT') {
        final type = (a['asset_type'] ?? '').toString().toLowerCase();
        if (!type.contains('joint')) return false;
      } else if (selectedFilter == 'SWITCH') {
        final type = (a['asset_type'] ?? '').toString().toLowerCase();
        if (!type.contains('switch') && !type.contains('point')) return false;
      }

      // Search query
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final code = (a['asset_code'] ?? '').toString().toLowerCase();
        final type = (a['asset_type'] ?? '').toString().toLowerCase();
        final loc = (a['location'] ?? '').toString().toLowerCase();
        final zone = (a['railway_zone'] ?? '').toString().toLowerCase();
        return code.contains(q) || type.contains(q) || loc.contains(q) || zone.contains(q);
      }
      return true;
    }).toList();
  }

  Color _conditionColor(String? condition, String? riskLevel) {
    final c = (condition ?? '').toLowerCase();
    final r = (riskLevel ?? '').toUpperCase();
    if (c.contains('crit') || c.contains('poor') || r == 'CRITICAL' || r == 'HIGH') {
      return SmartRailTheme.danger;
    }
    if (c.contains('mod') || c.contains('warn') || r == 'MEDIUM') {
      return SmartRailTheme.amber;
    }
    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final filtered = _filteredAssets;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Track Assets Catalog',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: session.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: SmartRailTheme.navy,
              foregroundColor: Colors.white,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AssetFormScreen()),
                );
                _load();
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Asset', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search by Asset ID, Type, Zone, KM...',
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
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip('ALL', 'All (${assets.length})'),
                      const SizedBox(width: 8),
                      _buildChip('GOOD', 'Good / Healthy'),
                      const SizedBox(width: 8),
                      _buildChip('WARNING', 'Warning'),
                      const SizedBox(width: 8),
                      _buildChip('CRITICAL', 'Critical', isAlert: true),
                      const SizedBox(width: 8),
                      _buildChip('FASTENER', 'Fasteners'),
                      const SizedBox(width: 8),
                      _buildChip('TRACK', 'Track Rails'),
                      const SizedBox(width: 8),
                      _buildChip('JOINT', 'Fishplate Joints'),
                      const SizedBox(width: 8),
                      _buildChip('SWITCH', 'Switch Points'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Assets List with Photos
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'No matching assets found',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final asset = filtered[i];
                            final photoPath = _getAssetPhoto(asset);
                            final condColor = _conditionColor(
                              asset['condition']?.toString(),
                              asset['ai_risk_level']?.toString(),
                            );

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AssetDetailScreen(
                                        assetCode: asset['asset_code'].toString(),
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top Image Banner with Badges
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                            child: SizedBox(
                                              height: 140,
                                              width: double.infinity,
                                              child: Image.asset(
                                                photoPath,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Container(
                                                  color: const Color(0xFF0F172A),
                                                  child: const Center(
                                                    child: Icon(Icons.train_rounded,
                                                        color: Colors.white38, size: 48),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Gradient Shade
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.vertical(
                                                  top: Radius.circular(16),
                                                ),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.black.withValues(alpha: 0.4),
                                                    Colors.transparent,
                                                    Colors.black.withValues(alpha: 0.7),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Condition Badge (Top Right)
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: condColor,
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: condColor.withValues(alpha: 0.4),
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    condColor == SmartRailTheme.danger
                                                        ? Icons.error_outline_rounded
                                                        : condColor == SmartRailTheme.amber
                                                            ? Icons.warning_amber_rounded
                                                            : Icons.check_circle_outline_rounded,
                                                    color: Colors.white,
                                                    size: 13,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    asset['condition']?.toString() ?? 'Normal',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w800,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Asset Code Badge (Bottom Left of photo)
                                          Positioned(
                                            bottom: 10,
                                            left: 12,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.8),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: const Color(0xFF38BDF8),
                                                  width: 1.2,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.qr_code_2_rounded,
                                                      size: 14, color: Color(0xFF38BDF8)),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    asset['asset_code']?.toString() ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w900,
                                                      color: Colors.white,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Details Body
                                      Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    asset['asset_type']?.toString() ?? 'Track Asset',
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w800,
                                                      color: Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                ),
                                                if (asset['ai_risk_score'] != null)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: condColor.withValues(alpha: 0.12),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      'Risk: ${asset['ai_risk_score']}%',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w800,
                                                        color: condColor,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on_outlined,
                                                    size: 15, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    '${asset['location']} · ${asset['railway_zone'] ?? 'Indian Railways'}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey.shade600,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (asset['sensor'] != null) ...[
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Icon(Icons.sensors_rounded,
                                                      size: 15, color: Color(0xFF0284C7)),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      '${asset['sensor']}',
                                                      style: const TextStyle(
                                                        fontSize: 11.5,
                                                        color: Color(0xFF0369A1),
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                            const SizedBox(height: 12),
                                            const Divider(height: 1),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Inspected: ${asset['last_inspection'] ?? 'Recent'}',
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    if (session.isInspector || session.isAdmin)
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  InspectionScreen(asset: asset),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(
                                                              horizontal: 10, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFFF1F5F9),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: const Text(
                                                            'Inspect',
                                                            style: TextStyle(
                                                              fontSize: 11.5,
                                                              fontWeight: FontWeight.bold,
                                                              color: SmartRailTheme.navy,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    const SizedBox(width: 8),
                                                    const Text(
                                                      'Details',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: SmartRailTheme.accent,
                                                      ),
                                                    ),
                                                    const Icon(
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
                                    ],
                                  ),
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

  Widget _buildChip(String key, String label, {bool isAlert = false}) {
    final isSelected = selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}
