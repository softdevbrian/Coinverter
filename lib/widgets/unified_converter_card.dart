import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/color_palette.dart';
import '../providers/currency_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/currency_data.dart';
import '../utils/formatters.dart';
import 'swap_button.dart';

/// Modern FinTech-style unified dual conversion card (inspired by Wise & Revolut).
/// Integrates "YOU SEND" and "YOU RECEIVE" in a single continuous card with an
/// embedded floating swap button, currency selection pills, and copy-on-tap.
class UnifiedConverterCard extends StatefulWidget {
  final TextEditingController amountController;
  final VoidCallback onSelectFromCurrency;
  final VoidCallback onSelectToCurrency;
  final VoidCallback onSwap;

  const UnifiedConverterCard({
    super.key,
    required this.amountController,
    required this.onSelectFromCurrency,
    required this.onSelectToCurrency,
    required this.onSwap,
  });

  @override
  State<UnifiedConverterCard> createState() => _UnifiedConverterCardState();
}

class _UnifiedConverterCardState extends State<UnifiedConverterCard> {
  void _copyResult(BuildContext context, String text) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('$text copied to clipboard')),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = provider.result;
    final toCurrency = provider.toCurrency;
    final fromCurrency = provider.fromCurrency;
    final decimals = provider.decimalPlaces;
    final symbol = getCurrencySymbol(toCurrency);

    final fullText =
        CurrencyFormatter.full(result, toCurrency, decimals: decimals);

    final cardBg = isDark ? const Color(0xFF161722) : Colors.white;
    final subtleBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final labelColor = isDark ? kTextSecondaryDark : kTextSecondaryLight;
    final textColor = isDark ? kTextPrimaryDark : kTextPrimaryLight;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: subtleBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : palette.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // ─── UPPER: YOU SEND ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'YOU SEND',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: labelColor,
                      ),
                    ),
                    _CurrencyPill(
                      code: fromCurrency,
                      onTap: widget.onSelectFromCurrency,
                      palette: palette,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      getCurrencySymbol(fromCurrency),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: palette.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: widget.amountController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                        inputFormatters: [_CurrencyInputFormatter()],
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) {
                          provider.convertDebounced(val);
                        },
                      ),
                    ),
                    if (widget.amountController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.cancel_rounded,
                          size: 20,
                          color: isDark ? Colors.white38 : Colors.black26,
                        ),
                        onPressed: () {
                          widget.amountController.clear();
                          provider.convertDebounced('');
                        },
                        splashRadius: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ─── MIDDLE: DIVIDER + FLOATING SWAP ─────────────────────────────
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
              Positioned(
                child: SwapButton(onTap: widget.onSwap),
              ),
            ],
          ),

          // ─── LOWER: YOU RECEIVE ──────────────────────────────────────────
          InkWell(
            onTap: result > 0
                ? () => _copyResult(
                    context, '$symbol $fullText $toCurrency')
                : null,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'YOU RECEIVE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: labelColor,
                            ),
                          ),
                          if (result > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: palette.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.copy_rounded,
                                      size: 10, color: palette.primary),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Copy',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: palette.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      _CurrencyPill(
                        code: toCurrency,
                        onTap: widget.onSelectToCurrency,
                        palette: palette,
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        symbol,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: palette.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: provider.isConverting
                            ? SizedBox(
                                height: 32,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: palette.primary,
                                    ),
                                  ),
                                ),
                              )
                            : Align(
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  alignment: Alignment.centerLeft,
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    result == 0.0 ? '0.00' : fullText,
                                    key: ValueKey(fullText),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: result == 0.0
                                          ? (isDark
                                              ? Colors.white24
                                              : Colors.black12)
                                          : textColor,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A sleek currency pill button displaying the flag, code, and a subtle chevron.
class _CurrencyPill extends StatelessWidget {
  final String code;
  final VoidCallback onTap;
  final AppColorPalette palette;
  final bool isDark;

  const _CurrencyPill({
    required this.code,
    required this.onTap,
    required this.palette,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF232434)
                : const Color(0xFFF3F4F8),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                getCurrencyFlag(code),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 6),
              Text(
                code,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? kTextPrimaryDark : kTextPrimaryLight,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: palette.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom input formatter to allow commas and decimal input.
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
