import 'package:flutter/material.dart';

class AppTheme {
  static Color _parse(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    final clean = hex.replaceAll('#', '');
    try {
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  static const Color _defaultPrimary    = Color(0xFF2563EB);
  static const Color _defaultSecondary  = Color(0xFF1E40AF);
  static const Color _defaultAccent     = Color(0xFFF59E0B);

  static ThemeData build({
    String? primaryHex,
    String? secondaryHex,
    String? accentHex,
  }) {
    final primary   = _parse(primaryHex, _defaultPrimary);
    final secondary = _parse(secondaryHex, _defaultSecondary);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size.fromHeight(52),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
