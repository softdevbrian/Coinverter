import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversion_result.dart';
import '../models/exchange_rate_cache.dart';
import '../utils/constants.dart';
import '../utils/currency_data.dart';

/// Central local-storage service.
/// Wraps [SharedPreferences] to handle all persistence needs:
/// - User preferences (selected currencies, theme, favorites)
/// - Cached exchange rates with timestamps
/// - Conversion history
class StorageService {
  late SharedPreferences _prefs;

  /// Must be called once at app startup before using any other methods.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Currency Preferences ──────────────────────────────────────────────────

  String get fromCurrency =>
      _prefs.getString(kKeyFromCurrency) ?? kDefaultFromCurrency;

  String get toCurrency =>
      _prefs.getString(kKeyToCurrency) ?? kDefaultToCurrency;

  Future<void> saveFromCurrency(String code) =>
      _prefs.setString(kKeyFromCurrency, code);

  Future<void> saveToCurrency(String code) =>
      _prefs.setString(kKeyToCurrency, code);

  // ─── Theme ─────────────────────────────────────────────────────────────────

  /// 0 = system, 1 = light, 2 = dark
  int get themeMode => _prefs.getInt(kKeyThemeMode) ?? 0;

  Future<void> saveThemeMode(int mode) =>
      _prefs.setInt(kKeyThemeMode, mode);

  // ─── Decimal Places ────────────────────────────────────────────────────────

  int get decimalPlaces =>
      _prefs.getInt(kKeyDecimalPlaces) ?? kDefaultDecimalPlaces;

  Future<void> saveDecimalPlaces(int places) =>
      _prefs.setInt(kKeyDecimalPlaces, places);

  // ─── Color Palette ─────────────────────────────────────────────────────────

  int get colorPaletteIndex => _prefs.getInt(kKeyColorPalette) ?? 0;

  Future<void> saveColorPaletteIndex(int index) =>
      _prefs.setInt(kKeyColorPalette, index);

  // ─── Favorites ─────────────────────────────────────────────────────────────

  List<String> get favorites =>
      _prefs.getStringList(kKeyFavorites) ?? [];

  Future<void> saveFavorites(List<String> codes) =>
      _prefs.setStringList(kKeyFavorites, codes);

  // ─── Exchange Rate Cache ───────────────────────────────────────────────────

  /// Persist rates and a timestamp to SharedPreferences.
  Future<void> saveRates(Map<String, double> rates) async {
    await _prefs.setString(kKeyRatesJson, jsonEncode(rates));
    await _prefs.setString(
        kKeyRatesTimestamp, DateTime.now().toIso8601String());
  }

  /// Load cached rates. Returns null if no cache exists.
  ExchangeRateCache? loadCachedRates() {
    final json = _prefs.getString(kKeyRatesJson);
    final tsStr = _prefs.getString(kKeyRatesTimestamp);
    if (json == null || tsStr == null) return null;

    try {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      final rates = decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
      final ts = DateTime.parse(tsStr);
      return ExchangeRateCache(rates: rates, lastUpdated: ts, isFromApi: true);
    } catch (_) {
      return null;
    }
  }

  /// Returns the built-in fallback rates (used only when fully offline with no cache).
  ExchangeRateCache get fallbackRates => ExchangeRateCache(
        rates: Map<String, double>.from(kFallbackRates),
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(0),
        isFromApi: false,
      );

  // ─── Conversion History ────────────────────────────────────────────────────

  List<ConversionResult> loadHistory() {
    final json = _prefs.getStringList(kKeyHistory) ?? [];
    return json
        .map((s) {
          try {
            return ConversionResult.fromJson(
                jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<ConversionResult>()
        .toList();
  }

  Future<void> saveHistory(List<ConversionResult> history) async {
    final capped = history.take(kHistoryMaxItems).toList();
    final json = capped.map((r) => jsonEncode(r.toJson())).toList();
    await _prefs.setStringList(kKeyHistory, json);
  }

  Future<void> clearHistory() => _prefs.remove(kKeyHistory);
}
