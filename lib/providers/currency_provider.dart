import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/conversion_result.dart';
import '../models/exchange_rate_cache.dart';
import '../services/connectivity_service.dart';
import '../services/exchange_rate_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../utils/currency_data.dart';

enum RateLoadState { idle, loading, loaded, error }

/// Central state manager for currency data, conversions, history, and favorites.
///
/// Responsibilities:
/// - Loads cached rates on startup (instant)
/// - Fetches live rates in background
/// - Persists all user preferences
/// - Manages conversion history (capped at [kHistoryMaxItems])
/// - Manages favorites list
class CurrencyProvider extends ChangeNotifier {
  final StorageService _storage;
  final ExchangeRateService _rateService;
  final ConnectivityService _connectivity;

  ExchangeRateCache? _cache;
  RateLoadState _rateState = RateLoadState.idle;

  String _fromCurrency = kDefaultFromCurrency;
  String _toCurrency = kDefaultToCurrency;
  double _result = 0.0;
  double _exchangeRate = 0.0;
  bool _isConverting = false;

  List<ConversionResult> _history = [];
  List<String> _favorites = [];
  bool _isOnline = true;
  int _decimalPlaces = kDefaultDecimalPlaces;

  Timer? _debounce;
  StreamSubscription<bool>? _connectivitySub;

  // ─── Getters ───────────────────────────────────────────────────────────────

  String get fromCurrency => _fromCurrency;
  String get toCurrency => _toCurrency;
  double get result => _result;
  double get exchangeRate => _exchangeRate;
  bool get isConverting => _isConverting;
  RateLoadState get rateState => _rateState;
  ExchangeRateCache? get cache => _cache;
  List<ConversionResult> get history => List.unmodifiable(_history);
  List<String> get favorites => List.unmodifiable(_favorites);
  bool get isOnline => _isOnline;
  int get decimalPlaces => _decimalPlaces;
  Map<String, double> get rates => _cache?.rates ?? kFallbackRates;

  bool get usingCachedRates =>
      _cache != null && (_cache!.isStale || !_cache!.isFromApi);

  CurrencyProvider({
    required StorageService storage,
    required ExchangeRateService rateService,
    required ConnectivityService connectivity,
  })  : _storage = storage,
        _rateService = rateService,
        _connectivity = connectivity;

  // ─── Initialization ────────────────────────────────────────────────────────

  Future<void> init() async {
    // 1. Load persisted preferences immediately
    _fromCurrency = _storage.fromCurrency;
    _toCurrency = _storage.toCurrency;
    _favorites = List<String>.from(_storage.favorites);
    _history = _storage.loadHistory();
    _decimalPlaces = _storage.decimalPlaces;
    _isOnline = _connectivity.isOnline;

    // 2. Load cached rates for instant offline-ready display
    final cached = _storage.loadCachedRates();
    if (cached != null) {
      _cache = cached;
      _rateState = RateLoadState.loaded;
    } else {
      _cache = _storage.fallbackRates;
    }
    notifyListeners();

    // 3. Fetch live rates in the background
    _fetchRates();

    // 4. Listen to connectivity changes
    _connectivitySub = _connectivity.onlineStream.listen((online) {
      _isOnline = online;
      notifyListeners();
      if (online) _fetchRates(); // refresh when reconnecting
    });
  }

  Future<void> _fetchRates() async {
    _rateState = RateLoadState.loading;
    notifyListeners();
    try {
      final fresh = await _rateService.fetchRates();
      _cache = fresh;
      _rateState = RateLoadState.loaded;
    } catch (_) {
      _rateState = RateLoadState.error;
    }
    notifyListeners();
  }

  /// Force-refresh rates (e.g. pull-to-refresh).
  Future<void> refreshRates() => _fetchRates();

  // ─── Currency Selection ────────────────────────────────────────────────────

  void setFromCurrency(String code) {
    if (_fromCurrency == code) return;
    _fromCurrency = code;
    _storage.saveFromCurrency(code);
    notifyListeners();
  }

  void setToCurrency(String code) {
    if (_toCurrency == code) return;
    _toCurrency = code;
    _storage.saveToCurrency(code);
    notifyListeners();
  }

  void swapCurrencies() {
    final tmp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = tmp;
    _storage.saveFromCurrency(_fromCurrency);
    _storage.saveToCurrency(_toCurrency);
    notifyListeners();
  }

  // ─── Conversion ────────────────────────────────────────────────────────────

  /// Debounced conversion — waits 350 ms after the last call before computing.
  void convertDebounced(String rawInput) {
    _debounce?.cancel();
    if (rawInput.isEmpty) {
      _result = 0.0;
      _exchangeRate = 0.0;
      notifyListeners();
      return;
    }
    _debounce = Timer(kDebounceDelay, () => _doConvert(rawInput));
  }

  /// Immediate conversion (e.g. on swap or currency change).
  void convertImmediate(String rawInput) {
    _debounce?.cancel();
    if (rawInput.isEmpty) return;
    _doConvert(rawInput);
  }

  void _doConvert(String rawInput) {
    final clean = rawInput.replaceAll(',', '');
    final amount = double.tryParse(clean);
    if (amount == null || amount < 0) {
      _result = 0.0;
      notifyListeners();
      return;
    }

    _isConverting = true;
    notifyListeners();

    final converted = _rateService.convert(
      amount: amount,
      from: _fromCurrency,
      to: _toCurrency,
      rates: rates,
    );

    // Calculate display exchange rate (1 unit of from → X to)
    _exchangeRate = _rateService.convert(
      amount: 1,
      from: _fromCurrency,
      to: _toCurrency,
      rates: rates,
    );

    _result = converted;
    _isConverting = false;

    // Record in history if meaningful
    if (amount > 0) {
      _addToHistory(ConversionResult(
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
        inputAmount: amount,
        convertedAmount: converted,
        exchangeRate: _exchangeRate,
        timestamp: DateTime.now(),
      ));
    }

    notifyListeners();
  }

  // ─── History ───────────────────────────────────────────────────────────────

  void _addToHistory(ConversionResult result) {
    _history.insert(0, result);
    if (_history.length > kHistoryMaxItems) {
      _history = _history.sublist(0, kHistoryMaxItems);
    }
    _storage.saveHistory(_history);
  }

  void deleteHistoryItem(int index) {
    _history.removeAt(index);
    _storage.saveHistory(_history);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    _storage.clearHistory();
    notifyListeners();
  }

  // ─── Favorites ─────────────────────────────────────────────────────────────

  void toggleFavorite(String code) {
    if (_favorites.contains(code)) {
      _favorites.remove(code);
    } else {
      _favorites.add(code);
    }
    _storage.saveFavorites(_favorites);
    notifyListeners();
  }

  bool isFavorite(String code) => _favorites.contains(code);

  // ─── Settings ──────────────────────────────────────────────────────────────

  void setDecimalPlaces(int places) {
    _decimalPlaces = places;
    _storage.saveDecimalPlaces(places);
    notifyListeners();
  }

  // ─── Dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _debounce?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }
}
