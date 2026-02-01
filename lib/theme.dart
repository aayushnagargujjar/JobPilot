import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primary = Color(0xFF6366f1);
  static const secondary = Color(0xFFa855f7);
  static const dark = Color(0xFF09090b);
  static const surface = Color(0xFF18181b);

  static ThemeData get theme => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: dark,
    primaryColor: primary,
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
  );
}