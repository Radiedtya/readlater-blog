import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'routes/app_routing.dart';

void main() => runApp(const ReadLaterApp());

class ReadLaterApp extends StatelessWidget {
  const ReadLaterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReadLater',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRouting.splash,
      onGenerateRoute: AppRouting.onGenerateRoute,
      theme: _buildTheme(),
    );
  }
}

ThemeData _buildTheme() {
  const primaryColor = Color(0xFF1E1E1E);
  const surfaceColor = Colors.white;
  const backgroundColor = Color(0xFFF7F6F2);
  const errorColor = Color(0xFFE57373);

  const colorScheme = ColorScheme.light(
    primary: primaryColor,
    onPrimary: Colors.white,
    surface: surfaceColor,
    onSurface: primaryColor,
    surfaceContainerHighest: Color(0xFFF0EFEA),
    outlineVariant: Color(0xFFEEEEEE),
    error: errorColor,
    onError: Colors.white,
  );

  final base = GoogleFonts.interTextTheme();

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: backgroundColor,
    textTheme: base.copyWith(
      displayLarge: GoogleFonts.fraunces(
          fontSize: 56, fontWeight: FontWeight.w500, color: primaryColor, height: 1.05),
      displayMedium: GoogleFonts.fraunces(
          fontSize: 40, fontWeight: FontWeight.w500, color: primaryColor, height: 1.1),
      displaySmall: GoogleFonts.fraunces(
          fontSize: 32, fontWeight: FontWeight.w500, color: primaryColor, height: 1.15),
      headlineMedium: GoogleFonts.fraunces(
          fontSize: 26, fontWeight: FontWeight.w500, color: primaryColor),
      titleLarge: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: primaryColor),
      titleMedium: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor),
      titleSmall: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor),
      bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w400, color: primaryColor, height: 1.6),
      bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400, color: primaryColor, height: 1.5),
      bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black54, height: 1.4),
      labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: primaryColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24), // Lebih membulat
        borderSide: BorderSide.none, // Tanpa garis luar
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      labelStyle: GoogleFonts.inter(color: Colors.black54),
      floatingLabelStyle: GoogleFonts.inter(color: primaryColor),
      hintStyle: GoogleFonts.inter(color: Colors.black38),
      prefixIconColor: Colors.black45,
      suffixIconColor: Colors.black45,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryColor,
      contentTextStyle: GoogleFonts.inter(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}