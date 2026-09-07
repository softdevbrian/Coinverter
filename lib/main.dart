import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'providers/currency_provider.dart';
import 'providers/theme_provider.dart';
import 'services/connectivity_service.dart';
import 'services/exchange_rate_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Non-blocking system UI and orientation configuration
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // ── Initialize services concurrently ─────────────────────────────────────
  final storage = StorageService();
  final connectivity = ConnectivityService();

  await Future.wait([
    storage.init(),
    connectivity.init(),
  ]);

  final rateService = ExchangeRateService(storage);

  // ── Initialize providers ─────────────────────────────────────────────────
  final themeProvider = ThemeProvider(storage);

  final currencyProvider = CurrencyProvider(
    storage: storage,
    rateService: rateService,
    connectivity: connectivity,
  );

  // ── Launch app immediately ───────────────────────────────────────────────
  runApp(
    CoinverterApp(
      storageService: storage,
      currencyProvider: currencyProvider,
      themeProvider: themeProvider,
    ),
  );
}
