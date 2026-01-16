import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette - Full Focus & Spiritual Calm
  static const Color warmCream = Color(0xFFFFFDF5); // Background for reading screen
  static const Color offWhite = Color(0xFFFFFDF5);
  static const Color deepSageGreen = Color(0xFF2D5A27); // Primary accents
  static const Color softCharcoal = Color(0xFF333333); // Text color
  static const Color lightSageGreen = Color(0xFFA8D5BA); // Light green for gradient
  static const Color mediumSageGreen = Color(0xFF5A8A5A); // Medium green
  static const Color accentGreen = Color(0xFF2D5A27); // Deep sage green
  
  // Legacy colors (for backward compatibility)
  static const Color softSageGreen = Color(0xFFE8F5E9);
  static const Color cream = Color(0xFFFFFDF5);
  static const Color deepCharcoal = Color(0xFF333333);
  static const Color darkSageGreen = Color(0xFF2D5A27);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepSageGreen,
        primary: deepSageGreen,
        secondary: mediumSageGreen,
        surface: warmCream,
        background: warmCream,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: softCharcoal,
        onBackground: softCharcoal,
      ),
      scaffoldBackgroundColor: warmCream,
      cardColor: warmCream,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          color: softCharcoal,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.inter(
          color: softCharcoal,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
        ),
        bodyLarge: GoogleFonts.inter(
          color: softCharcoal,
          fontSize: 16,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.inter(
          color: softCharcoal,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: warmCream,
        foregroundColor: softCharcoal,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardTheme(
        color: warmCream,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepSageGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: warmCream,
        selectedItemColor: deepSageGreen,
        unselectedItemColor: softCharcoal.withOpacity(0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 12),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
      ),
    );
  }
  
  // Arabic text style with Amiri font
  static TextStyle arabicTextStyle({
    required double fontSize,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.amiri(
      fontSize: fontSize,
      color: color ?? softCharcoal,
      height: height ?? 1.8,
      letterSpacing: 0,
    );
  }
  
  // English/Turkish UI text style with Inter
  static TextStyle uiTextStyle({
    required double fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      color: color ?? softCharcoal,
      fontWeight: fontWeight ?? FontWeight.w400,
      height: 1.5,
    );
  }
}
