import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinerColors {
  // Primary palette — Acid Green on near-black, ~90% black per brand brief.
  static const Color primary = Color(0xFFC6FF3A);      // Acid / Toxic Green
  static const Color primaryLight = Color(0xFFDFFF8A);
  static const Color primaryDark = Color(0xFF8FCC1E);

  // Accent — a second, cooler lime for gradient depth. Still green family;
  // the brand uses exactly one accent hue, not two competing colors.
  static const Color accent = Color(0xFF9EFF6B);
  static const Color accentLight = Color(0xFFD4FFB0);

  // Backgrounds — deep matte black / graphite / dark gray.
  static const Color background = Color(0xFF050505);
  static const Color surface = Color(0xFF111111);
  static const Color surfaceCard = Color(0xFF161616);
  static const Color surfaceElevated = Color(0xFF1E1E1E);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF8F8F8F);
  static const Color textHint = Color(0xFF4D4D4D);

  // Semantic — income reuses the brand accent (money in = the good color);
  // expense/info stay functional/neutral rather than adding new brand hues.
  static const Color income = Color(0xFFC6FF3A);
  static const Color expense = Color(0xFFFF5C7A);
  static const Color warning = Color(0xFFC6FF3A);
  static const Color info = Color(0xFF9EFF6B);

  // Gradients
  static const List<Color> heroGradient = [
    Color(0xFF141405),
    Color(0xFF0A0A05),
    Color(0xFF050505),
  ];

  static const List<Color> primaryGradient = [
    Color(0xFFC6FF3A),
    Color(0xFF7ED321),
  ];

  static const List<Color> incomeGradient = [
    Color(0xFFC6FF3A),
    Color(0xFF8FCC1E),
  ];

  static const List<Color> expenseGradient = [
    Color(0xFFFF5C7A),
    Color(0xFFFF2D55),
  ];

  static const List<Color> goldGradient = [
    Color(0xFFDFFF8A),
    Color(0xFFC6FF3A),
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
        onPrimary: Colors.black,
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
          foregroundColor: Colors.black,
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
