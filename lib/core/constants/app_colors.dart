import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF1A5FD6);
  static const Color primaryLight = Color(0xFFE8F0FE);
  static const Color primaryDark  = Color(0xFF0D3D99);

  // ── Status ─────────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF1A9E5C);
  static const Color successLight = Color(0xFFE3F7ED);
  static const Color warning      = Color(0xFFD68910);
  static const Color warningLight = Color(0xFFFEF5E4);
  static const Color error        = Color(0xFFC0392B);
  static const Color errorLight   = Color(0xFFFDECEA);

  // ── Neutral scale ──────────────────────────────────────────────────────────
  static const Color gray50  = Color(0xFFF7F8FA);
  static const Color gray100 = Color(0xFFF0F1F5);
  static const Color gray200 = Color(0xFFE1E4EC);
  static const Color gray400 = Color(0xFF9CA3B2);
  static const Color gray600 = Color(0xFF5B6380);
  static const Color gray800 = Color(0xFF1E2235);

  // ── Primary mid ────────────────────────────────────────────────────────────
  static const Color primaryMid = Color(0xFF134EB7);

  // ── Dark theme ─────────────────────────────────────────────────────────────
  static const Color darkBg         = Color(0xFF0F0F1A);
  static const Color darkSurface    = Color(0xFF1C1C2E);
  static const Color whiteOverlay60 = Color(0x99FFFFFF);
  static const Color white12        = Color(0x1FFFFFFF);
  static const Color white20        = Color(0x33FFFFFF);
  static const Color white60        = Color(0x99FFFFFF);

  // ── Payment brands ─────────────────────────────────────────────────────────
  static const Color gcash = Color(0xFF007DFC);
}
