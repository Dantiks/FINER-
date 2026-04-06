import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinerColors {
  // Primary palette
  static const Color primary = Color(0xFF6C63FF);      // Deep Purple
  static const Color primaryLight = Color(0xFF9C8FFF);
  static const Color primaryDark = Color(0xFF4A42CC);
  
  // Accent
  static const Color accent = Color(0xFF00D8A8);       // Mint Green
  static const Color accentLight = Color(0xFF5FFFFF);
  
  // Backgrounds
  static const Color background = Color(0xFF0D0D1A);   // Deep navy
  static const Color surface = Color(0xFF161628);
  static const Color surfaceCard = Color(0xFF1E1E35);
  static const Color surfaceElevated = Color(0xFF252540);
  
  // Text
  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF9090B0);
  static const Color textHint = Color(0xFF505070);
  
  // Semantic
  static const Color income = Color(0xFF00C896);       // Income green
  static const Color expense = Color(0xFFFF5C7A);      // Expense red
  static const Color warning = Color(0xFFFFB347);      // Warning orange
  static const Color info = Color(0xFF4FC3F7);         // Info blue
  
  // Gradients
  static const List<Color> heroGradient = [
    Color(0xFF1A1040),
    Color(0xFF0D1A40),
    Color(0xFF0D0D1A),
  ];
  
  static const List<Color> primaryGradient = [
    Color(0xFF6C63FF),
    Color(0xFF9C3FE4),
  ];
  
  static const List<Color> incomeGradient = [
    Color(0xFF00C896),
    Color(0xFF00A878),
  ];
  
  static const List<Color> expenseGradient = [
    Color(0xFFFF5C7A),
    Color(0xFFFF2D55),
  ];
  
  static const List<Color> goldGradient = [
    Color(0xFFFFD700),
    Color(0xFFF4A023),
  ];
}

class FinerTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: FinerColors.background,
      colorScheme: const ColorScheme.dark(
        primary: FinerColors.primary,
        secondary: FinerColors.accent,
        surface: FinerColors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: FinerColors.textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          color: FinerColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.inter(
          color: FinerColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: GoogleFonts.inter(
          color: FinerColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.inter(
          color: FinerColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.inter(
          color: FinerColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(
          color: FinerColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.inter(
          color: FinerColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.inter(
          color: FinerColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: FinerColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: FinerColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: FinerColors.surface,
        selectedItemColor: FinerColors.primary,
        unselectedItemColor: FinerColors.textHint,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: FinerColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FinerColors.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: FinerColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          color: FinerColors.textHint,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FinerColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
