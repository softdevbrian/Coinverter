import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/color_palette.dart';
import '../models/conversion_result.dart';
import '../providers/currency_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/currency_data.dart';
import '../utils/formatters.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
                    const Expanded(
                      child: Text(
                        'Conversion History',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Consumer<CurrencyProvider>(
                      builder: (context, provider, _) {
                        if (provider.history.isEmpty) return const SizedBox();
                        return TextButton(
                          onPressed: () => _confirmClearAll(context, provider),
                          child: const Text(
                            'Clear all',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Content
              Expanded(
                child: Consumer<CurrencyProvider>(
                  builder: (context, provider, _) {
                    final history = provider.history;
                    if (history.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildHistoryList(context, provider, palette);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded,
              color: Colors.white.withValues(alpha: 0.4), size: 64),
          const SizedBox(height: 16),
          Text(
            'No conversions yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your past conversions will appear here.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    CurrencyProvider provider,
    AppColorPalette palette,
  ) {
    final history = provider.history;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? kTextPrimaryDark : kTextPrimaryLight;

    // Group by date label
    final groups = <String, List<MapEntry<int, ConversionResult>>>{};
    for (int i = 0; i < history.length; i++) {
      final label = CurrencyFormatter.groupLabel(history[i].timestamp);
      groups.putIfAbsent(label, () => []).add(MapEntry(i, history[i]));
    }

    final keys = groups.keys.toList();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 24, left: 16, right: 16),
        itemCount: keys.length,
        itemBuilder: (context, groupIndex) {
          final label = keys[groupIndex];
          final entries = groups[label]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: palette.primary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Card(
                elevation: 0,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kBorderRadius),
                  side: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(kBorderRadius),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
                    ),
                    itemBuilder: (context, idx) {
                      final entry = entries[idx];
                      return _buildHistoryTile(
                        context,
                        provider,
                        entry.value,
                        entry.key,
                        palette,
                        textColor,
                        isDark,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistoryTile(
    BuildContext context,
    CurrencyProvider provider,
    ConversionResult item,
    int index,
    AppColorPalette palette,
    Color textColor,
    bool isDark,
  ) {
    final inputFormatted =
        CurrencyFormatter.full(item.inputAmount, item.fromCurrency);
    final resultFormatted =
        CurrencyFormatter.full(item.convertedAmount, item.toCurrency);
    final fromFlag = getCurrencyFlag(item.fromCurrency);
    final toFlag = getCurrencyFlag(item.toCurrency);
    final subtextColor = isDark ? kTextSecondaryDark : kTextSecondaryLight;

    return Dismissible(
      key: ValueKey('${item.timestamp.millisecondsSinceEpoch}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: kError.withValues(alpha: 0.15),
        child: const Icon(Icons.delete_rounded, color: kError),
      ),
      onDismissed: (_) => provider.deleteHistoryItem(index),
      child: ListTile(
        onTap: () {
          // Re-apply this conversion on the main screen
          provider.setFromCurrency(item.fromCurrency);
          provider.setToCurrency(item.toCurrency);
          Navigator.pop(context, item.inputAmount);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [palette.primary, palette.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              fromFlag,
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        title: Text(
          '$fromFlag $inputFormatted ${item.fromCurrency}  →  $toFlag $resultFormatted ${item.toCurrency}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
            color: textColor,
          ),
        ),
        subtitle: Text(
          CurrencyFormatter.formatDate(item.timestamp),
          style: TextStyle(fontSize: 11, color: subtextColor),
        ),
        trailing: Icon(Icons.chevron_right_rounded,
            color: subtextColor.withValues(alpha: 0.6), size: 18),
      ),
    );
  }

  void _confirmClearAll(BuildContext context, CurrencyProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
            'Are you sure you want to delete all conversion history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(ctx);
            },
            child: const Text('Clear All', style: TextStyle(color: kError)),
          ),
        ],
      ),
    );
  }
}
