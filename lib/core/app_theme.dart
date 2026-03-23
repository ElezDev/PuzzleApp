import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand Colors ──
  static const Color primaryLight = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF8B83FF);
  static const Color accent = Color(0xFFFF6B9D);
  static const Color success = Color(0xFF4ECDC4);
  static const Color warning = Color(0xFFFFBE76);
  static const Color error = Color(0xFFFF6B6B);

  static const Color _surfaceLight = Color(0xFFF8F9FE);
  static const Color _surfaceDark = Color(0xFF1A1B2E);
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _cardDark = Color(0xFF252742);
  static const Color _bgLight = Color(0xFFF0F1FA);
  static const Color _bgDark = Color(0xFF12131E);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryLight,
      secondary: accent,
      tertiary: success,
      surface: _surfaceLight,
      error: error,
    ),
    scaffoldBackgroundColor: _bgLight,
    cardColor: _cardLight,
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D2D3A)),
        displayMedium: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D2D3A)),
        headlineLarge: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D2D3A)),
        headlineMedium: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D2D3A)),
        headlineSmall: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D2D3A)),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D2D3A)),
        titleMedium: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF2D2D3A)),
        bodyLarge: TextStyle(color: Color(0xFF4A4A5A)),
        bodyMedium: TextStyle(color: Color(0xFF4A4A5A)),
        labelLarge: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D2D3A)),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: const Color(0xFF2D2D3A),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF2D2D3A)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    cardTheme: CardThemeData(
      color: _cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _cardLight,
      selectedItemColor: primaryLight,
      unselectedItemColor: const Color(0xFFB0B0C0),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryDark,
      secondary: accent,
      tertiary: success,
      surface: _surfaceDark,
      error: error,
    ),
    scaffoldBackgroundColor: _bgDark,
    cardColor: _cardDark,
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFE8E8F0)),
        displayMedium: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFE8E8F0)),
        headlineLarge: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFE8E8F0)),
        headlineMedium: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFE8E8F0)),
        headlineSmall: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFE8E8F0)),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFE8E8F0)),
        titleMedium: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFE8E8F0)),
        bodyLarge: TextStyle(color: Color(0xFFB0B0C8)),
        bodyMedium: TextStyle(color: Color(0xFFB0B0C8)),
        labelLarge: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFE8E8F0)),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: const Color(0xFFE8E8F0),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFE8E8F0)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    cardTheme: CardThemeData(
      color: _cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _cardDark,
      selectedItemColor: primaryDark,
      unselectedItemColor: const Color(0xFF6A6A80),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
    ),
  );
}
