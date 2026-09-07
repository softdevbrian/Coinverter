import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/color_palette.dart';
import '../providers/currency_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/currency_data.dart';
import '../widgets/currency_selector_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<ThemeProvider>().palette;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: palette.brandGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(kBorderRadiusLarge)),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _sectionHeader('Appearance', palette.primary),
                      _ThemeSetting(),
                      const SizedBox(height: 16),

                      _sectionHeader('Color Theme', palette.primary),
                      _ColorPaletteSetting(),
                      const SizedBox(height: 16),

                      _sectionHeader('Default Currencies', palette.primary),
                      _DefaultCurrencySetting(),
                      const SizedBox(height: 16),

                      _sectionHeader('Display', palette.primary),
                      _DecimalPlacesSetting(),
                      const SizedBox(height: 16),

                      _sectionHeader('Exchange Rates', palette.primary),
                      _RateCacheInfo(),
                      const SizedBox(height: 24),

                      _sectionHeader('About', palette.primary),
                      _AboutSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 1.2,
          ),
        ),
      );
}

// ─── Theme Setting ─────────────────────────────────────────────────────────

class _ThemeSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final accent = themeProvider.palette.primary;
    return _SettingsCard(
      child: Column(
        children: [
          _themeOption(context, themeProvider, accent, ThemeMode.system, Icons.brightness_auto_rounded, 'System default'),
          const Divider(height: 1),
          _themeOption(context, themeProvider, accent, ThemeMode.light, Icons.light_mode_rounded, 'Light'),
          const Divider(height: 1),
          _themeOption(context, themeProvider, accent, ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
        ],
      ),
    );
  }

  Widget _themeOption(
    BuildContext context,
    ThemeProvider provider,
    Color accent,
    ThemeMode mode,
    IconData icon,
    String label,
  ) {
    final isSelected = provider.themeMode == mode;
    return ListTile(
      leading: Icon(icon, color: isSelected ? accent : Colors.grey),
      title: Text(label,
          style: TextStyle(
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal)),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: accent)
          : null,
      onTap: () => provider.setTheme(mode),
    );
  }
}

// ─── Color Palette Setting ─────────────────────────────────────────────────

class _ColorPaletteSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final currentIndex = themeProvider.paletteIndex;

    return _SettingsCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose a color theme',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Changes the gradient and accent colors throughout the app.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: kColorPalettes.length,
              itemBuilder: (context, index) {
                final p = kColorPalettes[index];
                final isSelected = index == currentIndex;
                return GestureDetector(
                  onTap: () => themeProvider.setPalette(index),
                  child: AnimatedContainer(
                    duration: kAnimDurationFast,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(color: p.primary, width: 2.5)
                          : Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                              width: 1,
                            ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Color circle
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [p.primary, p.secondary],
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: p.primary.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 18)
                              : Center(
                                  child: Text(
                                    p.emoji,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? p.primary
                                : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Default Currencies ────────────────────────────────────────────────────

class _DefaultCurrencySetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CurrencyProvider>();
    final accent = context.watch<ThemeProvider>().palette.primary;
    return _SettingsCard(
      child: Column(
        children: [
          ListTile(
            leading: Text(getCurrencyFlag(provider.fromCurrency),
                style: const TextStyle(fontSize: 24)),
            title: const Text('Default "From" currency'),
            subtitle: Text(
                '${provider.fromCurrency} — ${getCurrencyName(provider.fromCurrency)}'),
            trailing: Icon(Icons.chevron_right_rounded, color: accent),
            onTap: () async {
              final selected = await CurrencySelectorSheet.show(
                context,
                selected: provider.fromCurrency,
                title: 'Default From',
              );
              if (selected != null) provider.setFromCurrency(selected);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Text(getCurrencyFlag(provider.toCurrency),
                style: const TextStyle(fontSize: 24)),
            title: const Text('Default "To" currency'),
            subtitle: Text(
                '${provider.toCurrency} — ${getCurrencyName(provider.toCurrency)}'),
            trailing: Icon(Icons.chevron_right_rounded, color: accent),
            onTap: () async {
              final selected = await CurrencySelectorSheet.show(
                context,
                selected: provider.toCurrency,
                title: 'Default To',
              );
              if (selected != null) provider.setToCurrency(selected);
            },
          ),
        ],
      ),
    );
  }
}

// ─── Decimal Places ────────────────────────────────────────────────────────

class _DecimalPlacesSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CurrencyProvider>();
    final accent = context.watch<ThemeProvider>().palette.primary;
    return _SettingsCard(
      child: Column(
        children: [2, 4, 6].map((places) {
          final isSelected = provider.decimalPlaces == places;
          return Column(
            children: [
              if (places != 2) const Divider(height: 1),
              ListTile(
                title: Text('$places decimal places'),
                subtitle: Text(
                    places == 2
                        ? 'e.g. 129.28'
                        : places == 4
                            ? 'e.g. 129.2800'
                            : 'e.g. 129.280000',
                    style: const TextStyle(fontSize: 12)),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: accent)
                    : null,
                onTap: () => provider.setDecimalPlaces(places),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Rate Cache Info ───────────────────────────────────────────────────────

class _RateCacheInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CurrencyProvider>();
    final accent = context.watch<ThemeProvider>().palette.primary;
    final cache = provider.cache;
    return _SettingsCard(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.cloud_sync_rounded, color: accent),
            title: const Text('Last rate update'),
            subtitle: Text(
              cache == null
                  ? 'Never updated'
                  : cache.isFromApi
                      ? 'Live API — ${cache.ageDescription}'
                      : '⚠️ Using built-in fallback rates',
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: provider.rateState == RateLoadState.loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: accent),
                  )
                : Icon(Icons.refresh_rounded, color: accent),
            title: const Text('Refresh exchange rates'),
            subtitle: Text(
              provider.isOnline
                  ? 'Tap to fetch the latest rates'
                  : 'Currently offline',
            ),
            onTap: provider.isOnline ? provider.refreshRates : null,
          ),
        ],
      ),
    );
  }
}

// ─── About ─────────────────────────────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final accent = context.watch<ThemeProvider>().palette.primary;
    return _SettingsCard(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.monetization_on_rounded, color: accent),
            title: const Text('Coinverter'),
            subtitle: const Text('Version 2.0.0'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.api_rounded, color: accent),
            title: const Text('Exchange rates provided by'),
            subtitle: const Text('ExchangeRate-API (open.er-api.com)'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.storage_rounded, color: accent),
            title: const Text('Data stored locally'),
            subtitle:
                const Text('All preferences & cached rates stored on your device'),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Card ───────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: child,
      ),
    );
  }
}
