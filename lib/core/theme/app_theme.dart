import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores extraídos del diseño del PDF
  static const Color primaryColor = Color(0xFFFF8B3D); // Naranja principal
  static const Color secondaryColor = Color(0xFF00BFA5); // Verde Azulado (Refugios)
  static const Color backgroundColor = Color(0xFFFFFBF6); // Crema suave (Fondo)
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color textPrimaryColor = Color(0xFF2D3436);
  static const Color textSecondaryColor = Color(0xFF636E72);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryColor,
      ),
      textTheme: GoogleFonts.nunitoTextTheme().copyWith( // Nunito es más "amigable" para mascotas
        displayLarge: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimaryColor),
        displayMedium: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimaryColor),
        bodyLarge: GoogleFonts.nunito(fontSize: 16, color: textPrimaryColor),
        bodyMedium: GoogleFonts.nunito(fontSize: 14, color: textSecondaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryColor, width: 2)),
      ),
    );
  }
}