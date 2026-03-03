import 'package:flutter/material.dart';

// ── Light Minimal Design Tokens ──────────────────────────────

const Color kBgWhite = Color(0xFFFFFFFF);
const Color kCardLight = Color(0xFFFFFFFF);
const Color kCardLightAlt = Color(0xFFF5F5F5);
const Color kAccent = Color(0xFF0097A7); // Teal accent
const Color kAccentWarm = Color(0xFFE8A030); // Warm orange for secondary badges
const Color kTextPrimary = Color(0xFF212121);
const Color kTextSecondary = Color(0xB3212121); // ~70% black
const Color kTextTertiary = Color(0x61212121); // ~38% black
const Color kDivider = Color(0x1F000000); // ~12% black
const Color kDanger = Color(0xFFEF4444);

const double kCardRadius = 10.0;

// ── ThemeData ────────────────────────────────────────────────

ThemeData buildAppTheme() {
  return ThemeData.light().copyWith(
    scaffoldBackgroundColor: kBgWhite,
    colorScheme: const ColorScheme.light(primary: kAccent, surface: kBgWhite),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBgWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: kTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      iconTheme: IconThemeData(color: kTextPrimary),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: kBgWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: kTextPrimary,
      contentTextStyle: TextStyle(color: kBgWhite),
    ),
  );
}
