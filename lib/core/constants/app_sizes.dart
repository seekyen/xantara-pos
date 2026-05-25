import 'package:flutter/material.dart';

abstract final class AppSizes {
  // ── Spacing (8pt grid) ─────────────────────────────────────────────────────
  static const double xs  =  4;
  static const double sm  =  8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 24;
  static const double xxl = 32;

  // ── Interactive ────────────────────────────────────────────────────────────
  static const double minTouch     = 44;
  static const double buttonHeight = 48;

  // ── Padding ────────────────────────────────────────────────────────────────
  static const double cardPad = 12;
  static const double screenH = 14;

  // ── Border radius ──────────────────────────────────────────────────────────
  static const double rInput   =  8;
  static const double rCard    = 12;
  static const double rCardLg  = 14;
  static const double rButton  = 10;
  static const double rPhone   = 32;
  static const double rPill    = 20;
  static const double rBadgeSm =  6;
}

abstract final class AppShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0A000000), blurRadius:  4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 30, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0F000000), blurRadius:  8, offset: Offset(0, 3)),
  ];
}
