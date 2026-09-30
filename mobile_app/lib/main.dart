import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_rail/screens/splash/splash_screen.dart';
import 'package:smart_rail/services/session.dart';
import 'package:smart_rail/utils/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartRailApp());
}

class SmartRailApp extends StatelessWidget {
  const SmartRailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionController()..load(),
      child: MaterialApp(
        title: 'SmartRail',
        debugShowCheckedModeBanner: false,
        theme: SmartRailTheme.light(GoogleFonts.manropeTextTheme()),
        home: const SplashScreen(),
      ),
    );
  }
}
