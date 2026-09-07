import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/currency_data.dart';
import '../widgets/conversion_card.dart';
import '../widgets/currency_selector_sheet.dart';
import '../widgets/offline_banner.dart';
import '../widgets/rate_chart.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/swap_button.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: kAnimDurationSlow,
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _fadeAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeIn,
    );
    _slideController.forward();

    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrencyProvider>().init();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectFromCurrency() async {
    final provider = context.read<CurrencyProvider>();
    final selected = await CurrencySelectorSheet.show(
      context,
      selected: provider.fromCurrency,
      title: 'From Currency',
    );
    if (selected != null && mounted) {
      provider.setFromCurrency(selected);
      if (_amountController.text.isNotEmpty) {
        provider.convertImmediate(_amountController.text);
      }
    }
  }

  Future<void> _selectToCurrency() async {
    final provider = context.read<CurrencyProvider>();
    final selected = await CurrencySelectorSheet.show(
      context,
      selected: provider.toCurrency,
      title: 'To Currency',
    );
    if (selected != null && mounted) {
      provider.setToCurrency(selected);
      if (_amountController.text.isNotEmpty) {
        provider.convertImmediate(_amountController.text);
      }
    }
  }

  void _swap() {
    HapticFeedback.selectionClick();
    final provider = context.read<CurrencyProvider>();
    provider.swapCurrencies();
    if (_amountController.text.isNotEmpty) {
      provider.convertImmediate(_amountController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CurrencyProvider>();
    final palette = context.watch<ThemeProvider>().palette;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: palette.brandGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Offline banner
              OfflineBanner(
                isOnline: provider.isOnline,
                cacheAge: provider.cache?.ageDescription,
              ),

              // App bar row
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    kPaddingHorizontal, 12, kPaddingHorizontal, 0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Coinverter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                        if (provider.cache != null)
                          Text(
                            provider.cache!.isFromApi
                                ? 'Rates updated ${provider.cache!.ageDescription}'
                                : '⚠️ Using fallback rates',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    // Refresh button
                    if (provider.rateState == RateLoadState.loading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded,
                            color: Colors.white),
                        onPressed: provider.refreshRates,
                        tooltip: 'Refresh rates',
                      ),
                    IconButton(
                      icon: const Icon(Icons.history_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HistoryScreen()),
                      ),
                      tooltip: 'History',
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      ),
                      tooltip: 'Settings',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Main card
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: RefreshIndicator(
                      onRefresh: provider.refreshRates,
                      color: palette.primary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: kPaddingHorizontal),
                        child: provider.rateState == RateLoadState.idle
                            ? const ShimmerLoading()
                            : Column(
                                children: [
                                  // White content card
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(
                                          kBorderRadiusLarge),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.12),
                                          blurRadius: 24,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        // Amount input
                                        _buildAmountInput(context, provider, palette.primary),
                                        const SizedBox(height: 16),

                                        // From selector
                                        _buildCurrencyButton(
                                          context,
                                          label: 'FROM',
                                          code: provider.fromCurrency,
                                          onTap: _selectFromCurrency,
                                          accentColor: palette.primary,
                                        ),
                                        const SizedBox(height: 12),

                                        // Swap button
                                        Center(
                                          child: SwapButton(onTap: _swap),
                                        ),
                                        const SizedBox(height: 12),

                                        // To selector
                                        _buildCurrencyButton(
                                          context,
                                          label: 'TO',
                                          code: provider.toCurrency,
                                          onTap: _selectToCurrency,
                                          accentColor: palette.primary,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Conversion result
                                  const ConversionCard(),

                                  const SizedBox(height: 16),

                                  // Rate chart
                                  if (provider.exchangeRate > 0)
                                    RateChart(
                                      currentRate: provider.exchangeRate,
                                      fromCode: provider.fromCurrency,
                                      toCode: provider.toCurrency,
                                    ),

                                  const SizedBox(height: 24),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput(BuildContext context, CurrencyProvider provider, Color accentColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252538) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(
          color: isDark
              ? const Color(0xFF3A3A50)
              : Colors.grey.shade200,
        ),
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: isDark ? kTextPrimaryDark : kTextPrimaryLight,
        ),
        inputFormatters: [_CurrencyInputFormatter()],
        decoration: InputDecoration(
          hintText: 'Enter amount…',
          hintStyle: TextStyle(
            color: isDark ? Colors.white24 : Colors.grey.shade400,
            fontWeight: FontWeight.w400,
            fontSize: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixText:
              '${getCurrencySymbol(provider.fromCurrency)}  ',
          prefixStyle: TextStyle(
            color: accentColor,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        onChanged: (value) {
          provider.convertDebounced(value);
        },
      ),
    );
  }

  Widget _buildCurrencyButton(
    BuildContext context, {
    required String label,
    required String code,
    required VoidCallback onTap,
    required Color accentColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252538) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(kBorderRadius),
          border: Border.all(
            color: isDark
                ? const Color(0xFF3A3A50)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? kTextSecondaryDark
                    : kTextSecondaryLight,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              getCurrencyFlag(code),
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? kTextPrimaryDark : kTextPrimaryLight,
                  ),
                ),
                Text(
                  getCurrencyName(code),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? kTextSecondaryDark
                        : kTextSecondaryLight,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: accentColor, size: 22),
          ],
        ),
      ),
    );
  }
}

// ─── Input Formatter ───────────────────────────────────────────────────────

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');
    final parts = text.split('.');
    if (parts.length > 2) {
      text = '${parts[0]}.${parts.sublist(1).join('')}';
    }
    final split = text.split('.');
    String integer = split[0];
    final decimal = split.length > 1 ? '.${split[1]}' : '';
    if (integer.length > 3) {
      integer = integer.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    final formatted = '$integer$decimal';
    final oldCommas = oldValue.text.split(',').length - 1;
    final newCommas = formatted.split(',').length - 1;
    int sel =
        (newValue.selection.end + (newCommas - oldCommas)).clamp(0, formatted.length);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: sel),
    );
  }
}
