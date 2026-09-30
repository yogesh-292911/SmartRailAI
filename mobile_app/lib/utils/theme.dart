import 'package:flutter/material.dart';

class SmartRailTheme {
  static const navy = Color(0xFF0B1F3A);
  static const navyMid = Color(0xFF143056);
  static const accent = Color(0xFF1FA2A6);
  static const amber = Color(0xFFE0A106);
  static const danger = Color(0xFFD64545);
  static const ok = Color(0xFF2E8B57);
  static const bg = Color(0xFFF4F7FB);

  static ThemeData light(TextTheme textTheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: navy, primary: navy),
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

Color riskColor(String? level) {
  switch (level) {
    case 'HIGH':
      return SmartRailTheme.danger;
    case 'MEDIUM':
      return SmartRailTheme.amber;
    case 'LOW':
      return SmartRailTheme.ok;
    default:
      return SmartRailTheme.navyMid;
  }
}
