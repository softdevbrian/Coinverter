import 'package:flutter/material.dart';
import '../models/color_palette.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

/// Manages the app's theme (light / dark / system) and color palette.
/// Persists the user's choices via [StorageService].
class ThemeProvider extends ChangeNotifier {
  final StorageService _storage;
  late ThemeMode _themeMode;
  late int _paletteIndex;

  ThemeProvider(this._storage) {
    final saved = _storage.themeMode;
    _themeMode = switch (saved) {
      1 => ThemeMode.light,
      2 => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _paletteIndex = _storage.colorPaletteIndex.clamp(0, kColorPalettes.length - 1);
  }

  // ─── Theme Mode ────────────────────────────────────────────────────────────

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    _storage.saveThemeMode(switch (mode) {
      ThemeMode.light => 1,
      ThemeMode.dark => 2,
      _ => 0,
    });
    notifyListeners();
  }

  bool get isLight => _themeMode == ThemeMode.light;
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isSystem => _themeMode == ThemeMode.system;

  // ─── Color Palette ─────────────────────────────────────────────────────────

  int get paletteIndex => _paletteIndex;
  AppColorPalette get palette => kColorPalettes[_paletteIndex];

  void setPalette(int index) {
    _paletteIndex = index.clamp(0, kColorPalettes.length - 1);
    _storage.saveColorPaletteIndex(_paletteIndex);
    notifyListeners();
  }
}

// ─── Theme Definitions ─────────────────────────────────────────────────────

ThemeData buildLightTheme(AppColorPalette palette) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      cardTheme: CardThemeData(
        color: kCardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );

ThemeData buildDarkTheme(AppColorPalette palette) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: kSurfaceDark,
      cardTheme: CardThemeData(
        color: kCardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252538),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          borderSide: const BorderSide(color: Color(0xFF3A3A50)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          borderSide: const BorderSide(color: Color(0xFF3A3A50)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
