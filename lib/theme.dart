import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primary = Color(0xFF0A2540);
  static const secondary = Color(0xFF4F8CFF);
  static const dark = Color(0xFFF5FBF9);
  static const surface = Color(0xFFE2F2F6);
  static const background = Color(0xFFF5FBF9);

  static ThemeData get theme => ThemeData.light().copyWith(
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      onSurface: primary,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: primary,
      displayColor: primary,
    ),
  );
}