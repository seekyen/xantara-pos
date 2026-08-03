import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Xantara POS design tokens — "Refined Material" pass (option 1a).
/// Keeps the existing brand blue + Material 3 base, but replaces ad hoc
/// inline font sizes with a real named type scale and tightens card/
/// spacing rhythm.
class XantaraColors {
  XantaraColors._();

  static const primary = Color(0xFF1A5FD6);
  static const primaryLight = Color(0xFFE8F0FE);
  static const primaryDark = Color(0xFF0D3D99);

  static const success = Color(0xFF1A9E5C);
  static const warning = Color(0xFFD68910);
  static const warningBg = Color(0xFFFBF2E4);
  static const error = Color(0xFFC0392B);

  static const gray50 = Color(0xFFF7F8FA);
  static const gray100 = Color(0xFFF0F1F5);
  static const gray200 = Color(0xFFE1E4EC);
  static const gray400 = Color(0xFF9CA3B2);
  static const gray600 = Color(0xFF5B6380);
  static const gray900 = Color(0xFF1E2235);

  static const gcash = Color(0xFF007DFC);

  // Dark theme surfaces (structural — not yet given a dedicated pass).
  static const darkBg = Color(0xFF111827);
  static const darkSurface = Color(0xFF1F2937);
  static const darkSurfaceAlt = Color(0xFF374151);
}

class XantaraSpacing {
  XantaraSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class XantaraRadius {
  XantaraRadius._();
  static const input = 8.0;
  static const card = 12.0;
  static const cardLg = 14.0;
  static const button = 10.0;
  static const pill = 20.0;
  static const sheetTop = 32.0;
}

/// Named type scale — replaces the old 4 ad hoc styles
/// (heroNumber/statNumber/body/caption) with a full display/title/body/label
/// ramp, all on DM Sans. DM Mono is reserved for invoice/transaction numerals.
class XantaraType {
  XantaraType._();

  static TextStyle _sans(double size, FontWeight w, {double? letterSpacing, Color? color}) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: w,
        letterSpacing: letterSpacing,
        color: color ?? XantaraColors.gray900,
        height: 1.25,
      );

  static TextStyle _mono(double size, FontWeight w, {Color? color}) => GoogleFonts.dmMono(
        fontSize: size,
        fontWeight: w,
        color: color ?? XantaraColors.gray900,
        height: 1.2,
      );

  static TextStyle displayLg = _sans(28, FontWeight.w700, letterSpacing: -0.4);
  static TextStyle displayMd = _sans(22, FontWeight.w700, letterSpacing: -0.3);

  static TextStyle titleLg = _sans(17, FontWeight.w700);
  static TextStyle titleMd = _sans(15, FontWeight.w700);
  static TextStyle titleSm = _sans(13.5, FontWeight.w700);

  static TextStyle bodyLg = _sans(15, FontWeight.w400);
  static TextStyle bodyMd = _sans(13, FontWeight.w400);
  static TextStyle bodySm = _sans(12, FontWeight.w400);

  static TextStyle labelMd = _sans(12.5, FontWeight.w600);
  static TextStyle labelSm = _sans(11.5, FontWeight.w600, color: XantaraColors.gray400);
  static TextStyle labelCaps = _sans(11, FontWeight.w600, letterSpacing: 0.4, color: XantaraColors.gray400);

  static TextStyle statNumber = _sans(28, FontWeight.w700, letterSpacing: -0.3);
  static TextStyle heroNumber = _sans(36, FontWeight.w700, letterSpacing: -0.5);

  static TextStyle monoLg = _mono(22, FontWeight.w700);
  static TextStyle monoMd = _mono(13, FontWeight.w500);
  static TextStyle monoSm = _mono(11, FontWeight.w500);
}

ThemeData buildXantaraTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: XantaraColors.primary,
    scaffoldBackgroundColor: XantaraColors.gray50,
    fontFamily: GoogleFonts.dmSans().fontFamily,
  );

  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: XantaraColors.primary,
      error: XantaraColors.error,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(base.textTheme),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(XantaraRadius.card),
        side: const BorderSide(color: XantaraColors.gray200),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: XantaraColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        elevation: 0,
        textStyle: XantaraType.labelMd.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(XantaraRadius.button)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: XantaraColors.gray600,
        side: const BorderSide(color: XantaraColors.gray200),
        minimumSize: const Size.fromHeight(48),
        textStyle: XantaraType.labelMd,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(XantaraRadius.button)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: XantaraColors.gray50,
      contentPadding: const EdgeInsets.symmetric(horizontal: XantaraSpacing.lg, vertical: XantaraSpacing.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(XantaraRadius.input),
        borderSide: const BorderSide(color: XantaraColors.gray200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(XantaraRadius.input),
        borderSide: const BorderSide(color: XantaraColors.gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(XantaraRadius.input),
        borderSide: const BorderSide(color: XantaraColors.primary, width: 1.5),
      ),
    ),
  );
}
