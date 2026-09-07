import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/currency_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'services/storage_service.dart';

/// Root application widget.
/// Sets up [MultiProvider] with [CurrencyProvider] and [ThemeProvider],
/// and dynamically applies light/dark theming with the selected color palette.
class CoinverterApp extends StatelessWidget {
  final StorageService storageService;
  final CurrencyProvider currencyProvider;
  final ThemeProvider themeProvider;

  const CoinverterApp({
    super.key,
    required this.storageService,
    required this.currencyProvider,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: currencyProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Coinverter',
            debugShowCheckedModeBanner: false,
            themeMode: theme.themeMode,
            theme: buildLightTheme(theme.palette),
            darkTheme: buildDarkTheme(theme.palette),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
