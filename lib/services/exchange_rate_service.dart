import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exchange_rate_cache.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../utils/currency_data.dart';

/// Fetches live exchange rates from the ExchangeRate-API (free tier).
/// Falls back to cached rates, then hardcoded fallback rates if offline.
class ExchangeRateService {
  final StorageService _storage;

  ExchangeRateService(this._storage);

  /// Fetches fresh rates from the API.
  /// Returns an [ExchangeRateCache] — either from the API or from cache/fallback.
  Future<ExchangeRateCache> fetchRates() async {
    try {
      final response = await http
          .get(Uri.parse(kApiBaseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['result'] == 'success') {
          final rawRates = data['rates'] as Map<String, dynamic>;

          // Filter to only currencies we have metadata for
          final rates = <String, double>{};
          for (final entry in rawRates.entries) {
            if (kCurrencyMeta.containsKey(entry.key)) {
              rates[entry.key] = (entry.value as num).toDouble();
            }
          }

          // Always include USD base
          rates['USD'] = 1.0;

          // Persist the fresh rates
          await _storage.saveRates(rates);

          return ExchangeRateCache(
            rates: rates,
            lastUpdated: DateTime.now(),
            isFromApi: true,
          );
        }
      }
    } catch (_) {
      // Network error or timeout — fall through to cache
    }

    // Try cached rates first
    final cached = _storage.loadCachedRates();
    if (cached != null) return cached;

    // Last resort: hardcoded fallback
    return _storage.fallbackRates;
  }

  /// Converts [amount] from [from] currency to [to] currency using [rates].
  double convert({
    required double amount,
    required String from,
    required String to,
    required Map<String, double> rates,
  }) {
    final fromRate = rates[from] ?? 1.0;
    final toRate = rates[to] ?? 1.0;
    return (amount / fromRate) * toRate;
  }
}
