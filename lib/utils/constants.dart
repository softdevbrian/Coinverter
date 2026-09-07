import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Brand colours
// ---------------------------------------------------------------------------
const Color kPrimary = Color(0xFF667eea);
const Color kSecondary = Color(0xFF764ba2);
const Color kAccent = Color(0xFFf093fb);

const List<Color> kGradientColors = [kPrimary, kSecondary, kAccent];

// Card / surface
const Color kCardLight = Colors.white;
const Color kCardDark = Color(0xFF1E1E2C);
const Color kSurfaceDark = Color(0xFF13131F);

// Text
const Color kTextPrimaryLight = Color(0xFF1A1A2E);
const Color kTextSecondaryLight = Color(0xFF6B7280);
const Color kTextPrimaryDark = Color(0xFFF3F4F6);
const Color kTextSecondaryDark = Color(0xFF9CA3AF);

// Status
const Color kSuccess = Color(0xFF10B981);
const Color kError = Color(0xFFEF4444);
const Color kWarning = Color(0xFFF59E0B);
const Color kOffline = Color(0xFFEF4444);

// ---------------------------------------------------------------------------
// Dimensions
// ---------------------------------------------------------------------------
const double kBorderRadius = 16.0;
const double kBorderRadiusLarge = 24.0;
const double kBorderRadiusSmall = 10.0;
const double kPaddingHorizontal = 20.0;
const double kPaddingVertical = 16.0;

// ---------------------------------------------------------------------------
// Gradients
// ---------------------------------------------------------------------------
const LinearGradient kBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kPrimary, kSecondary, kAccent],
);

const LinearGradient kCardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kPrimary, kSecondary],
);

// ---------------------------------------------------------------------------
// Durations
// ---------------------------------------------------------------------------
const Duration kAnimDurationFast = Duration(milliseconds: 200);
const Duration kAnimDurationMedium = Duration(milliseconds: 400);
const Duration kAnimDurationSlow = Duration(milliseconds: 800);
const Duration kDebounceDelay = Duration(milliseconds: 350);
const Duration kCacheMaxAge = Duration(hours: 1);

// ---------------------------------------------------------------------------
// Storage keys
// ---------------------------------------------------------------------------
const String kKeyFromCurrency = 'from_currency';
const String kKeyToCurrency = 'to_currency';
const String kKeyThemeMode = 'theme_mode';
const String kKeyFavorites = 'favorites';
const String kKeyHistory = 'history';
const String kKeyRatesJson = 'rates_json';
const String kKeyRatesTimestamp = 'rates_timestamp';
const String kKeyDecimalPlaces = 'decimal_places';
const String kKeyColorPalette = 'color_palette';

// ---------------------------------------------------------------------------
// Defaults
// ---------------------------------------------------------------------------
const String kDefaultFromCurrency = 'USD';
const String kDefaultToCurrency = 'KES';
const int kHistoryMaxItems = 50;
const int kDefaultDecimalPlaces = 2;

// ---------------------------------------------------------------------------
// API
// ---------------------------------------------------------------------------
const String kApiBaseUrl = 'https://open.er-api.com/v6/latest/USD';
