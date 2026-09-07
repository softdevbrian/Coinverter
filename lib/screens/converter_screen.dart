import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/currency_data.dart';
import '../utils/formatters.dart';
import '../widgets/currency_selector_sheet.dart';
import '../widgets/offline_banner.dart';
import '../widgets/rate_chart.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/unified_converter_card.dart';
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
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Quick select amounts
  final List<double> _quickAmounts = [10, 50, 100, 500, 1000];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: kAnimDurationMedium,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _animController.forward();

    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrencyProvider>().init();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectFromCurrency() async {
    final provider = context.read<CurrencyProvider>();
    final selected = await CurrencySelectorSheet.show(
      context,
      selected: provider.fromCurrency,
      title: 'Select Source Currency',
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
      title: 'Select Target Currency',
    );
    if (selected != null && mounted) {
      provider.setToCurrency(selected);
      if (_amountController.text.isNotEmpty) {
        provider.convertImmediate(_amountController.text);
      }
    }
  }

  void _swap() {
    HapticFeedback.mediumImpact();
    final provider = context.read<CurrencyProvider>();
    provider.swapCurrencies();
    if (_amountController.text.isNotEmpty) {
      provider.convertImmediate(_amountController.text);
    }
  }

  void _applyQuickAmount(double amount) {
    HapticFeedback.lightImpact();
    final text = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toString();
    _amountController.text = text;
    context.read<CurrencyProvider>().convertImmediate(text);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CurrencyProvider>();
    final palette = context.watch<ThemeProvider>().palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardBg = Theme.of(context).cardColor;
    final textColor = isDark ? kTextPrimaryDark : kTextPrimaryLight;
    final subtextColor = isDark ? kTextSecondaryDark : kTextSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ── Ambient Aurora Glow at Top ──────────────────────────────────
          Positioned(
            top: -50,
            left: -30,
            right: -30,
            height: 240,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.6),
                  radius: 0.95,
                  colors: [
                    palette.primary.withValues(alpha: isDark ? 0.22 : 0.14),
                    palette.secondary.withValues(alpha: isDark ? 0.08 : 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Offline banner
                OfflineBanner(
                  isOnline: provider.isOnline,
                  cacheAge: provider.cache?.ageDescription,
                ),

                // ── App Header ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  child: Row(
                    children: [
                      // App logo icon
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [palette.primary, palette.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: palette.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '💱',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coinverter',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: provider.isOnline ? kSuccess : kWarning,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                provider.cache != null && provider.cache!.isFromApi
                                    ? 'Live rates • ${provider.cache!.ageDescription}'
                                    : 'Offline • Cached rates',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: subtextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Action buttons
                      _ActionButton(
                        icon: provider.rateState == RateLoadState.loading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: palette.primary,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded, size: 20),
                        tooltip: 'Refresh rates',
                        onTap: provider.refreshRates,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _ActionButton(
                        icon: const Icon(Icons.history_rounded, size: 20),
                        tooltip: 'History',
                        onTap: () async {
                          final reuseAmount = await Navigator.push<double>(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HistoryScreen()),
                          );
                          if (reuseAmount != null && mounted) {
                            _applyQuickAmount(reuseAmount);
                          }
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _ActionButton(
                        icon: const Icon(Icons.settings_outlined, size: 20),
                        tooltip: 'Settings',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        ),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                // ── Main Content Scroll ────────────────────────────────────
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
                              horizontal: 20, vertical: 4),
                          child: provider.rateState == RateLoadState.idle
                              ? const ShimmerLoading()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),

                                    // ── Unified FinTech Card ───────────────
                                    UnifiedConverterCard(
                                      amountController: _amountController,
                                      onSelectFromCurrency: _selectFromCurrency,
                                      onSelectToCurrency: _selectToCurrency,
                                      onSwap: _swap,
                                    ),

                                    const SizedBox(height: 14),

                                    // ── Rate Strip ─────────────────────────
                                    if (provider.exchangeRate > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: cardBg,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.06)
                                                : Colors.black
                                                    .withValues(alpha: 0.05),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.trending_up_rounded,
                                              size: 16,
                                              color: palette.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                CurrencyFormatter.rateDisplay(
                                                  provider.fromCurrency,
                                                  provider.toCurrency,
                                                  provider.exchangeRate,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: textColor,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: palette.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                'Mid-market',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: palette.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    const SizedBox(height: 16),

                                    // ── Quick Amount Chips ─────────────────
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'QUICK AMOUNTS',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.0,
                                            color: subtextColor,
                                          ),
                                        ),
                                        Text(
                                          'Tap to fill',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: subtextColor
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 38,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _quickAmounts.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 8),
                                        itemBuilder: (context, index) {
                                          final val = _quickAmounts[index];
                                          final sym = getCurrencySymbol(
                                              provider.fromCurrency);
                                          final label =
                                              '$sym${val.toInt()}';
                                          final isCurrent = _amountController
                                                  .text ==
                                              val.toInt().toString();

                                          return ActionChip(
                                            label: Text(
                                              label,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: isCurrent
                                                    ? FontWeight.w700
                                                    : FontWeight.w600,
                                                color: isCurrent
                                                    ? Colors.white
                                                    : textColor,
                                              ),
                                            ),
                                            backgroundColor: isCurrent
                                                ? palette.primary
                                                : cardBg,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: BorderSide(
                                                color: isCurrent
                                                    ? palette.primary
                                                    : (isDark
                                                        ? Colors.white
                                                            .withValues(
                                                                alpha: 0.08)
                                                        : Colors.black
                                                            .withValues(
                                                                alpha: 0.06)),
                                              ),
                                            ),
                                            onPressed: () =>
                                                _applyQuickAmount(val),
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // ── Rate Trend Chart ───────────────────
                                    if (provider.exchangeRate > 0) ...[
                                      RateChart(
                                        currentRate: provider.exchangeRate,
                                        fromCode: provider.fromCurrency,
                                        toCode: provider.toCurrency,
                                      ),
                                      const SizedBox(height: 24),
                                    ],
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
        ],
      ),
    );
  }
}

/// Circular frosted/card action button for the app header.
class _ActionButton extends StatelessWidget {
  final Widget icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E1F2D)
                : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}
