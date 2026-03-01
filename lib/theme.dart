import 'package:flutter/material.dart';

// ── Ultra Minimal Design Tokens ──────────────────────────────

const Color kBgBlack = Color(0xFF000000);
const Color kCardDark = Color(0xFF111111);
const Color kCardDarkAlt = Color(0xFF1A1A1A);
const Color kAccent = Color(0xFF4DA3FF);
const Color kTextPrimary = Color(0xFFFFFFFF);
const Color kTextSecondary = Color(0xB3FFFFFF); // ~70% white
const Color kTextTertiary = Color(0x61FFFFFF); // ~38% white
const Color kDivider = Color(0x1AFFFFFF); // ~10% white
const Color kDanger = Color(0xFFEF4444);

const double kCardRadius = 10.0;

// ── ThemeData ────────────────────────────────────────────────

ThemeData buildAppTheme() {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: kBgBlack,
    colorScheme: const ColorScheme.dark(primary: kAccent, surface: kBgBlack),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBgBlack,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: kTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      iconTheme: IconThemeData(color: kTextPrimary),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: kCardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: kCardDark,
      contentTextStyle: TextStyle(color: kTextPrimary),
    ),
  );
}
