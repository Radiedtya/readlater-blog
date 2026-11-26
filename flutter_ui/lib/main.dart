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
  const background = Color(0xFFFAF9F6); // warm paper
  const surface = Color(0xFFFFFFFF);
  const onSurface = Color(0xFF1A1A1A);
  const onSurfaceVariant = Color(0xFF6B6B6B);
  const outlineVariant = Color(0xFFE6E3DD);
  const surfaceHighest = Color(0xFFF1EFEA);
  const accent = Color(0xFF1A1A1A);
  const error = Color(0xFFB3261E);

  const colorScheme = ColorScheme.light(
    primary: accent,
    onPrimary: Colors.white,
    secondary: onSurfaceVariant,
    onSecondary: Colors.white,
    surface: surface,
    onSurface: onSurface,
    surfaceContainerHighest: surfaceHighest,
    outline: Color(0xFFD6D2CA),
    outlineVariant: outlineVariant,
    error: error,
    onError: Colors.white,
  );

  final base = GoogleFonts.interTextTheme();

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    textTheme: base.copyWith(
      displayLarge: GoogleFonts.fraunces(
          fontSize: 56, fontWeight: FontWeight.w500, color: onSurface, height: 1.05),
      displayMedium: GoogleFonts.fraunces(
          fontSize: 40, fontWeight: FontWeight.w500, color: onSurface, height: 1.1),
      displaySmall: GoogleFonts.fraunces(
          fontSize: 32, fontWeight: FontWeight.w500, color: onSurface, height: 1.15),
      headlineMedium: GoogleFonts.fraunces(
          fontSize: 26, fontWeight: FontWeight.w500, color: onSurface),
      titleLarge: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),
      titleMedium: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600, color: onSurface),
      titleSmall: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: onSurface),
      bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w400, color: onSurface, height: 1.6),
      bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400, color: onSurface, height: 1.5),
      bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400, color: onSurfaceVariant, height: 1.4),
      labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: onSurface),
      labelSmall: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w600, color: onSurfaceVariant, letterSpacing: 0.4),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600, color: onSurface),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: onSurface, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: error, width: 1.4),
      ),
      labelStyle: GoogleFonts.inter(color: onSurfaceVariant),
      floatingLabelStyle: GoogleFonts.inter(color: onSurface),
      hintStyle: GoogleFonts.inter(color: onSurfaceVariant),
      prefixIconColor: onSurfaceVariant,
      suffixIconColor: onSurfaceVariant,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: onSurface,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        side: const BorderSide(color: outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: onSurface,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: outlineVariant, thickness: 1, space: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: surfaceHighest,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.all(
        GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? onSurface : onSurfaceVariant,
          size: 22,
        );
      }),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      elevation: 0,
      highlightElevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: onSurface,
      contentTextStyle: GoogleFonts.inter(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}