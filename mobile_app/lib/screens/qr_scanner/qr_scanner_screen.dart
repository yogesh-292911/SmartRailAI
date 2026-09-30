import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:smart_rail/screens/assets/asset_detail_screen.dart';
import 'package:smart_rail/services/session.dart';
import 'package:smart_rail/utils/theme.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _controller;
  late final AnimationController _scanLineAnimController;

  bool _isTorchOn = false;
  bool _useRearCamera = true;
  bool _cameraHasError = false;
  String? _cameraErrorMessage;
  bool _forceSimulationMode = false;

  String? detectedAssetCode;
  Map<String, dynamic>? detectedAssetInfo;
  bool showDetectedSheet = false;

  String? selectedAssetCode;
  List<Map<String, dynamic>> assetOptions = [];
  bool loadingAssets = true;

  @override
  void initState() {
    super.initState();
    _initScanner();
    _scanLineAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadAssetOptions();
  }

  void _initScanner() {
    // Determine if hardware camera can be safely initialized
    final isDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);

    if (isDesktop) {
      _forceSimulationMode = true;
    }

    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      returnImage: false,
    );
  }

  @override
  void dispose() {
    _scanLineAnimController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAssetOptions() async {
    try {
      final session = context.read<SessionController>();
      final res = await session.api.get('/api/assets').catchError((_) => null);
      if (res is List && res.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          assetOptions = List<Map<String, dynamic>>.from(
            res.map((e) => Map<String, dynamic>.from(e as Map)),
          );
          selectedAssetCode = assetOptions.first['asset_code']?.toString();
          loadingAssets = false;
        });
        return;
      }
    } catch (_) {}

    if (!mounted) return;
    // Standard Indian Railways demo assets
    setState(() {
      assetOptions = [
        {
          'asset_code': 'SR-TRK-00145',
          'asset_type': 'Rail Fastener / Clip',
          'location': 'KM 124/6 (Chennai-Arakkonam)',
          'status': 'HEALTHY',
        },
        {
          'asset_code': 'IR-TRACK-102',
          'asset_type': 'Broad Gauge Rail Track',
          'location': 'KM 142/4 (Chennai-New Delhi)',
          'status': 'CRITICAL',
        },
        {
          'asset_code': 'SR-TRK-00048',
          'asset_type': 'Concrete Sleeper & Rail',
          'location': 'KM 12/4 (Madurai-Dindigul)',
          'status': 'WARNING',
        },
        {
          'asset_code': 'SR-TRK-00021',
          'asset_type': 'Fish Plate Joint',
          'location': 'KM 86/2 (Jolarpettai-Salem)',
          'status': 'WARNING',
        },
        {
          'asset_code': 'SR-TRK-00034',
          'asset_type': 'Rail Bolt & Elastic Pad',
          'location': 'KM 42/1 (Bangalore-Mysore)',
          'status': 'HEALTHY',
        },
        {
          'asset_code': 'SR-TRK-WR009',
          'asset_type': 'Switch Point Component',
          'location': 'Point 14A (Basin Bridge Yard)',
          'status': 'CRITICAL',
        },
      ];
      selectedAssetCode = 'SR-TRK-00145';
      loadingAssets = false;
    });
  }

  void _onQrDetected(String code) {
    final cleanCode = code.trim();
    if (cleanCode.isEmpty) return;

    // Find asset match in database / options
    final match = assetOptions.firstWhere(
      (a) => a['asset_code'] == cleanCode,
      orElse: () => {
        'asset_code': cleanCode,
        'asset_type': 'Track Asset',
        'location': 'KM 124/6 (Chennai-Arakkonam)',
      },
    );

    setState(() {
      detectedAssetCode = cleanCode;
      detectedAssetInfo = match;
      showDetectedSheet = true;
    });
  }

  void _navigateToAsset(String code) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AssetDetailScreen(assetCode: code)),
    );
  }

  Future<void> _toggleTorch() async {
    setState(() => _isTorchOn = !_isTorchOn);
    try {
      await _controller.toggleTorch();
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    setState(() {
      _useRearCamera = !_useRearCamera;
      if (_forceSimulationMode) {
        // Toggle simulation perspective
      }
    });
    try {
      await _controller.switchCamera();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          'Scan QR Code',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        actions: [
          // Torch Button
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: _isTorchOn ? const Color(0xFFFBBF24) : Colors.white70,
            ),
            tooltip: _isTorchOn ? 'Torch On' : 'Torch Off',
            onPressed: _toggleTorch,
          ),
          // Switch Camera
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white70),
            tooltip: 'Switch Camera',
            onPressed: _switchCamera,
          ),
          // Camera / Simulation Mode Toggle
          IconButton(
            icon: Icon(
              _forceSimulationMode ? Icons.camera_alt_outlined : Icons.videocam_rounded,
              color: _forceSimulationMode ? const Color(0xFF38BDF8) : Colors.white70,
              size: 20,
            ),
            tooltip: _forceSimulationMode ? 'Simulated Optical Feed' : 'Live Camera',
            onPressed: () {
              setState(() {
                _forceSimulationMode = !_forceSimulationMode;
                _cameraHasError = false;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Main Camera / Laser Viewfinder
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Camera View
                if (!_forceSimulationMode && !_cameraHasError)
                  MobileScanner(
                    controller: _controller,
                    errorBuilder: (context, error, child) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && !_cameraHasError) {
                          setState(() {
                            _cameraHasError = true;
                            _cameraErrorMessage = error.errorDetails?.message ??
                                'Hardware camera unavailable on this device.';
                          });
                        }
                      });
                      return _buildSimulatedTrackFeed();
                    },
                    onDetect: (capture) {
                      for (final barcode in capture.barcodes) {
                        final val = barcode.rawValue;
                        if (val != null && val.isNotEmpty) {
                          _onQrDetected(val);
                          break;
                        }
                      }
                    },
                  )
                else
                  _buildSimulatedTrackFeed(),

                // Flashlight Overlay if Torch Enabled
                if (_isTorchOn)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.8,
                          colors: [
                            Colors.amber.withValues(alpha: 0.18),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                // Targeting Reticle with Corner Brackets
                Center(
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      children: [
                        // Reticle Corners
                        CustomPaint(
                          size: const Size(260, 260),
                          painter: _ScannerReticlePainter(
                            color: showDetectedSheet
                                ? const Color(0xFF10B981)
                                : const Color(0xFF38BDF8),
                          ),
                        ),

                        // Moving Laser Scan Line Animation
                        AnimatedBuilder(
                          animation: _scanLineAnimController,
                          builder: (context, child) {
                            return Positioned(
                              top: 20 + (_scanLineAnimController.value * 220),
                              left: 10,
                              right: 10,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      showDetectedSheet
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFEF4444),
                                      Colors.white,
                                      showDetectedSheet
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFEF4444),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (showDetectedSheet
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFEF4444))
                                          .withValues(alpha: 0.8),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Top Status Tag
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _forceSimulationMode
                                ? 'HIGH-RES OPTICAL SCANNER (TAP QR TO SCAN)'
                                : (_cameraHasError
                                    ? (_cameraErrorMessage ?? 'OPTICAL SCANNER ACTIVE')
                                    : 'ALIGN LASER QR CODE INSIDE FRAME'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Detected Asset Sheet (Matching Mockup Screen 7)
                if (showDetectedSheet && detectedAssetCode != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: _buildAssetFoundCard(),
                  ),
              ],
            ),
          ),

          // HTML-Style Select Dropdown & Quick Presets Section
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.qr_code_2_rounded, size: 20, color: Color(0xFF38BDF8)),
                        SizedBox(width: 8),
                        Text(
                          'Direct Asset Code Selection',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (loadingAssets)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF38BDF8)),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Dropdown Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedAssetCode,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E293B),
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF38BDF8), size: 28),
                      items: [
                        for (final item in assetOptions)
                          DropdownMenuItem<String>(
                            value: item['asset_code'].toString(),
                            child: Row(
                              children: [
                                const Icon(Icons.inventory_2_outlined,
                                    size: 16, color: Color(0xFF38BDF8)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${item['asset_code']} • ${item['asset_type']} (${item['location'] ?? ''})',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => selectedAssetCode = val);
                          _onQrDetected(val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Quick Preset Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text(
                        'Quick Select: ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      for (final item in assetOptions.take(4))
                        GestureDetector(
                          onTap: () {
                            setState(() => selectedAssetCode = item['asset_code'].toString());
                            _onQrDetected(item['asset_code'].toString());
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: selectedAssetCode == item['asset_code']
                                  ? const Color(0xFF0284C7)
                                  : const Color(0xFF334155),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              item['asset_code'].toString(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: selectedAssetCode == item['asset_code']
                                    ? Colors.white
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Button to open selected asset
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (selectedAssetCode != null && selectedAssetCode!.isNotEmpty) {
                      _navigateToAsset(selectedAssetCode!);
                    }
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text(
                    'OPEN SELECTED TRACK ASSET',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Realistic Track Viewfinder with Scannable QR Tag (Matching Mockup Screen 7)
  Widget _buildSimulatedTrackFeed() {
    return GestureDetector(
      onTap: () => _onQrDetected('SR-TRK-00145'),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Railway Track Image with laser QR plate
          Image.asset(
            'assets/images/laser_qr_scan.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF0F172A),
              child: const Center(
                child: Icon(Icons.qr_code_scanner, size: 80, color: Color(0xFF38BDF8)),
              ),
            ),
          ),

          // Dark vignette overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),

          // Scannable Laser QR Tag Hint
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _onQrDetected('SR-TRK-00145'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded, color: Color(0xFF34D399), size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Tap Laser QR Plate [SR-TRK-00145] to Scan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Exact Card from Mockup Screen 7: "Asset Found"
  Widget _buildAssetFoundCard() {
    final code = detectedAssetCode ?? 'SR-TRK-00145';
    final type = detectedAssetInfo?['asset_type'] ?? 'Track Asset';
    final loc = detectedAssetInfo?['location'] ?? 'KM 124/6';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Asset Found',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '$type | $loc',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => setState(() => showDetectedSheet = false),
                  child: const Text('Scan Another'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SmartRailTheme.navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _navigateToAsset(code),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text(
                    'View Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Painter for targeting reticle corner brackets
class _ScannerReticlePainter extends CustomPainter {
  _ScannerReticlePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 32.0;

    // Top Left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom Left
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Bottom Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant _ScannerReticlePainter oldDelegate) =>
      oldDelegate.color != color;
}
