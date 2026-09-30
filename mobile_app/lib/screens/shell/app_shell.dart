import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_rail/screens/assets/asset_list_screen.dart';
import 'package:smart_rail/screens/dashboard/dashboard_screen.dart';
import 'package:smart_rail/screens/live_status/live_status_map_screen.dart';
import 'package:smart_rail/screens/login/login_screen.dart';
import 'package:smart_rail/screens/maintenance/maintenance_list_screen.dart';
import 'package:smart_rail/screens/qr_scanner/qr_scanner_screen.dart';
import 'package:smart_rail/screens/reports/reports_screen.dart';
import 'package:smart_rail/screens/alerts/maintenance_alerts_screen.dart';
import 'package:smart_rail/screens/users/users_screen.dart';
import 'package:smart_rail/services/session.dart';
import 'package:smart_rail/utils/theme.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final tabs = <_TabItem>[
      _TabItem('Home', Icons.dashboard_outlined, const DashboardScreen()),
      if (session.isInspector || session.isAdmin)
        _TabItem('Scan', Icons.qr_code_scanner, const QrScannerScreen()),
      if (session.isMaintenance || session.isAdmin)
        _TabItem('Jobs', Icons.build_outlined, const MaintenanceListScreen()),
      if (session.isAdmin)
        _TabItem('Assets', Icons.inventory_2_outlined, const AssetListScreen()),
      if (session.isAdmin)
        _TabItem('Reports', Icons.bar_chart, const ReportsScreen()),
    ];
    final safeIndex = index.clamp(0, tabs.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: SmartRailTheme.amber, width: 1.5),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.train,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SmartRail AI',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'Indian Railways Asset Hub',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Tool Section: Live Status Button (Available to Admin, Inspect, and Maintain users)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.25),
                foregroundColor: Colors.white,
                elevation: 0,
                side: const BorderSide(color: Color(0xFF10B981), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                minimumSize: const Size(0, 36),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LiveStatusMapScreen()),
                );
              },
              icon: const Icon(Icons.radar_rounded, color: Color(0xFF34D399), size: 16),
              label: const Text(
                'LIVE STATUS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Notification Bell with Badge (Screen 4: Maintenance Alerts)
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: SmartRailTheme.danger,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            tooltip: 'Maintenance Alerts (3)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MaintenanceAlertsScreen()),
              );
            },
          ),
          if (session.isAdmin)
            IconButton(
              icon: const Icon(Icons.people_outline),
              tooltip: 'Manage Users',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UsersScreen()),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await session.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: tabs[safeIndex].page,
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        indicatorColor: SmartRailTheme.accent.withValues(alpha: 0.2),
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: [
          for (final tab in tabs)
            NavigationDestination(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
    );
  }
}

class _TabItem {
  _TabItem(this.label, this.icon, this.page);
  final String label;
  final IconData icon;
  final Widget page;
}
