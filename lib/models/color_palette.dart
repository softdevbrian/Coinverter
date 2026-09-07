import 'package:flutter/material.dart';

/// Represents a selectable color theme for the app.
class AppColorPalette {
  final String name;
  final String emoji;
  final Color primary;
  final Color secondary;
  final Color accent;

  const AppColorPalette({
    required this.name,
    required this.emoji,
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  LinearGradient get brandGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, secondary, accent],
      );

  LinearGradient get cardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, secondary],
      );
}

/// All available color palettes.
const List<AppColorPalette> kColorPalettes = [
  AppColorPalette(
    name: 'Royal Purple',
    emoji: '💜',
    primary: Color(0xFF667eea),
    secondary: Color(0xFF764ba2),
    accent: Color(0xFFf093fb),
  ),
  AppColorPalette(
    name: 'Ocean Blue',
    emoji: '🌊',
    primary: Color(0xFF2196F3),
    secondary: Color(0xFF0D47A1),
    accent: Color(0xFF64B5F6),
  ),
  AppColorPalette(
    name: 'Emerald Green',
    emoji: '🌿',
    primary: Color(0xFF10B981),
    secondary: Color(0xFF047857),
    accent: Color(0xFF6EE7B7),
  ),
  AppColorPalette(
    name: 'Sunset Orange',
    emoji: '🌅',
    primary: Color(0xFFF97316),
    secondary: Color(0xFFEA580C),
    accent: Color(0xFFFBBF24),
  ),
  AppColorPalette(
    name: 'Rose Pink',
    emoji: '🌸',
    primary: Color(0xFFEC4899),
    secondary: Color(0xFFBE185D),
    accent: Color(0xFFF9A8D4),
  ),
  AppColorPalette(
    name: 'Midnight',
    emoji: '🌙',
    primary: Color(0xFF6366F1),
    secondary: Color(0xFF312E81),
    accent: Color(0xFF818CF8),
  ),
  AppColorPalette(
    name: 'Cherry Red',
    emoji: '🍒',
    primary: Color(0xFFEF4444),
    secondary: Color(0xFFB91C1C),
    accent: Color(0xFFFCA5A5),
  ),
  AppColorPalette(
    name: 'Golden',
    emoji: '✨',
    primary: Color(0xFFD4A843),
    secondary: Color(0xFF92700C),
    accent: Color(0xFFF0D78C),
  ),
];
