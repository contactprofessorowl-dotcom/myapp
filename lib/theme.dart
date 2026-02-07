import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Flash design system — friendly, accessible, all ages
const Color _primarySeed = Color(0xFF0D7377); // Teal — calm, focus, learning
const Color _secondarySeed = Color(0xFFF2A541); // Amber — warmth, energy

final TextTheme appTextTheme = TextTheme(
  displayLarge: GoogleFonts.nunito(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  ),
  displayMedium: GoogleFonts.nunito(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    height: 1.25,
  ),
  displaySmall: GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
  ),
  headlineLarge: GoogleFonts.nunito(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.35,
  ),
  headlineMedium: GoogleFonts.nunito(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.4,
  ),
  headlineSmall: GoogleFonts.nunito(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  ),
  titleLarge: GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  ),
  titleMedium: GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.45,
  ),
  titleSmall: GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.45,
  ),
  bodyLarge: GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.5,
  ),
  bodyMedium: GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  ),
  bodySmall: GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  ),
  labelLarge: GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  ),
  labelMedium: GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  ),
  labelSmall: GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  ),
);

// Light theme — warm, high contrast, easy on the eyes
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _primarySeed,
    primary: const Color(0xFF0D7377),
    secondary: _secondarySeed,
    surface: const Color(0xFFF8FAF9),
    brightness: Brightness.light,
    error: const Color(0xFFB00020),
  ),
  scaffoldBackgroundColor: const Color(0xFFF0F4F3),
  textTheme: appTextTheme,
  appBarTheme: AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: true,
    backgroundColor: const Color(0xFF0D7377),
    foregroundColor: Colors.white,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    titleTextStyle: GoogleFonts.nunito(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Colors.white, size: 24),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    color: Colors.white,
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF0D7377),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      minimumSize: const Size(88, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w700),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF0D7377),
      side: const BorderSide(color: Color(0xFF0D7377), width: 2),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      minimumSize: const Size(88, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w600),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFF0D7377),
    unselectedItemColor: Color(0xFF6B7280),
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    contentTextStyle: GoogleFonts.nunito(fontSize: 16, color: Colors.white),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF0D7377), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    hintStyle: GoogleFonts.nunito(color: Colors.grey.shade600, fontSize: 16),
  ),
);

// Dark theme — comfortable for evening use
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _primarySeed,
    primary: const Color(0xFF14B8A6),
    secondary: const Color(0xFFFBBF24),
    surface: const Color(0xFF1E293B),
    brightness: Brightness.dark,
    error: const Color(0xFFCF6679),
  ),
  scaffoldBackgroundColor: const Color(0xFF0F172A),
  textTheme: appTextTheme.apply(
    bodyColor: const Color(0xFFE2E8F0),
    displayColor: Colors.white,
  ),
  appBarTheme: AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: true,
    backgroundColor: const Color(0xFF0F172A),
    foregroundColor: Colors.white,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    titleTextStyle: GoogleFonts.nunito(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Colors.white, size: 24),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    color: const Color(0xFF1E293B),
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: const Color(0xFF0F172A),
      backgroundColor: const Color(0xFF14B8A6),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      minimumSize: const Size(88, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w700),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF14B8A6),
      side: const BorderSide(color: Color(0xFF14B8A6), width: 2),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      minimumSize: const Size(88, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w600),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1E293B),
    selectedItemColor: Color(0xFF14B8A6),
    unselectedItemColor: Color(0xFF94A3B8),
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    backgroundColor: const Color(0xFF334155),
    contentTextStyle: GoogleFonts.nunito(fontSize: 16, color: Colors.white),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E293B),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF475569)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    hintStyle: GoogleFonts.nunito(color: const Color(0xFF94A3B8), fontSize: 16),
  ),
);
