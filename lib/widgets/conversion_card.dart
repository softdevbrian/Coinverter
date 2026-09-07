import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/currency_data.dart';
import '../utils/formatters.dart';

/// The result card showing the converted amount, exchange rate, and copy button.
class ConversionCard extends StatefulWidget {
  const ConversionCard({super.key});

  @override
  State<ConversionCard> createState() => _ConversionCardState();
}

class _ConversionCardState extends State<ConversionCard>
    with SingleTickerProviderStateMixin {
  bool _showFullAmount = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: kAnimDurationFast,
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _pulse() {
    _pulseController.forward().then((_) => _pulseController.reverse());
  }

  void _copyToClipboard(BuildContext context, String text) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('$text copied to clipboard'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: kSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CurrencyProvider>();
    final palette = context.watch<ThemeProvider>().palette;
    final result = provider.result;
    final toCurrency = provider.toCurrency;
    final fromCurrency = provider.fromCurrency;
    final rate = provider.exchangeRate;
    final decimals = provider.decimalPlaces;

    final displayText = _showFullAmount
        ? CurrencyFormatter.full(result, toCurrency, decimals: decimals)
        : CurrencyFormatter.abbreviated(result, toCurrency, decimals: decimals);
    final fullText = CurrencyFormatter.full(result, toCurrency, decimals: decimals);
    final symbol = getCurrencySymbol(toCurrency);

    return GestureDetector(
      onLongPressStart: (_) => setState(() => _showFullAmount = true),
      onLongPressEnd: (_) => setState(() => _showFullAmount = false),
      onLongPressCancel: () => setState(() => _showFullAmount = false),
      onTap: result > 0
          ? () {
              _pulse();
              _copyToClipboard(context, '$symbol $fullText $toCurrency');
            }
          : null,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) => Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: palette.cardGradient,
            borderRadius: BorderRadius.circular(kBorderRadius),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Label row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _showFullAmount ? 'Full Amount' : 'Converted Amount',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (result > 0)
                    const Row(
                      children: [
                        Icon(Icons.copy_rounded,
                            color: Colors.white54, size: 13),
                        SizedBox(width: 3),
                        Text(
                          'Tap to copy',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Amount
              provider.isConverting
                  ? const SizedBox(
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        strokeWidth: 2.5,
                      ),
                    )
                  : AnimatedSwitcher(
                      duration: kAnimDurationFast,
                      child: RichText(
                        key: ValueKey(displayText),
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$symbol ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: displayText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '  $toCurrency',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

              if (rate > 0 && !provider.isConverting) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    CurrencyFormatter.rateDisplay(fromCurrency, toCurrency, rate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              if (_showFullAmount && result > 0) ...[
                const SizedBox(height: 6),
                const Text(
                  'Long press to see full amount',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
