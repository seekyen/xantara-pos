import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const TextStyle heroNumber = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: -0.5,
  );

  static const TextStyle statNumber = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.gray800,
  );

  static const TextStyle body = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.gray800,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.gray400,
  );

  // ── Named scale ("Refined Material" pass) ───────────────────────────────
  // DM Sans cascades from AppTheme's textTheme, so these stay plain
  // TextStyles (no explicit fontFamily); mono styles opt in explicitly.
  static const TextStyle displayLg = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: AppColors.gray800,
  );
  static const TextStyle displayMd = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.gray800,
  );

  static const TextStyle titleLg = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.gray800,
  );
  static const TextStyle titleMd = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.gray800,
  );
  static const TextStyle titleSm = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w700,
    color: AppColors.gray800,
  );

  static const TextStyle bodyLg = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.gray800,
  );
  static const TextStyle bodyMd = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.gray800,
  );
  static const TextStyle bodySm = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.gray800,
  );

  static const TextStyle labelMd = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: AppColors.gray800,
  );
  static const TextStyle labelSm = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    color: AppColors.gray400,
  );
  static const TextStyle labelCaps = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: AppColors.gray400,
  );

  static TextStyle monoLg = GoogleFonts.dmMono(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.gray800,
  );
  static TextStyle monoMd = GoogleFonts.dmMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.gray800,
  );
  static TextStyle monoSm = GoogleFonts.dmMono(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.gray800,
  );
}
