import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// Store settings
final branchProvider = StateProvider<String>((ref) => 'Main Branch');
final receiptHeaderProvider =
    StateProvider<String>((ref) => 'Thank you for shopping with us!');
final currencyProvider = StateProvider<String>((ref) => 'PHP');

// Preferences
final printOnCheckoutProvider = StateProvider<bool>((ref) => false);
final soundEffectsProvider = StateProvider<bool>((ref) => true);

// Predefined theme color options
class ThemeColor {
  final String label;
  final Color color;
  const ThemeColor(this.label, this.color);
}

const themeColorOptions = [
  ThemeColor('Navy', Color(0xFF1B2B5B)),
  ThemeColor('Blue', Color(0xFF1565C0)),
  ThemeColor('Teal', Color(0xFF00695C)),
  ThemeColor('Green', Color(0xFF2E7D32)),
  ThemeColor('Purple', Color(0xFF6A1B9A)),
  ThemeColor('Red', Color(0xFFC62828)),
  ThemeColor('Orange', Color(0xFFE65100)),
  ThemeColor('Brown', Color(0xFF4E342E)),
  ThemeColor('Indigo', Color(0xFF283593)),
  ThemeColor('Pink', Color(0xFFAD1457)),
];

final colorSeedProvider =
    StateProvider<Color>((ref) => themeColorOptions.first.color);
