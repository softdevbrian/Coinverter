import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/currency_data.dart';

/// A modal bottom sheet for selecting a currency.
/// Shows favorites, recently used currencies, then a full searchable list.
class CurrencySelectorSheet extends StatefulWidget {
  final String selectedCode;
  final String title;

  const CurrencySelectorSheet({
    super.key,
    required this.selectedCode,
    required this.title,
  });

  /// Shows the sheet and returns the selected currency code, or null if dismissed.
  static Future<String?> show(
    BuildContext context, {
    required String selected,
    required String title,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: context.read<CurrencyProvider>()),
          ChangeNotifierProvider.value(value: context.read<ThemeProvider>()),
        ],
        child: CurrencySelectorSheet(selectedCode: selected, title: title),
      ),
    );
  }

  @override
  State<CurrencySelectorSheet> createState() => _CurrencySelectorSheetState();
}

class _CurrencySelectorSheetState extends State<CurrencySelectorSheet> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<String> _filtered(List<String> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((code) {
      final name = getCurrencyName(code).toLowerCase();
      return code.toLowerCase().contains(q) || name.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CurrencyProvider>();
    final palette = context.watch<ThemeProvider>().palette;
    final favorites = provider.favorites;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? kCardDark : Colors.white;
    final textColor = isDark ? kTextPrimaryDark : kTextPrimaryLight;

    final allCodes = getSortedCurrencyCodes();
    final filteredAll = _filtered(allCodes);
    final filteredFaves =
        _query.isEmpty ? favorites : _filtered(favorites);
    final nonFaves = filteredAll.where((c) => !favorites.contains(c)).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(kBorderRadiusLarge),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _search,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search currency or code…',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Currency list
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  // Favorites section
                  if (filteredFaves.isNotEmpty) ...[
                    _sectionHeader('⭐ Favorites', textColor),
                    ...filteredFaves.map((code) => _currencyTile(
                          context,
                          code,
                          provider,
                          textColor,
                          palette.primary,
                        )),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    const SizedBox(height: 4),
                  ],

                  // All currencies
                  _sectionHeader('🌍 All Currencies', textColor),
                  ...nonFaves.map((code) => _currencyTile(
                        context,
                        code,
                        provider,
                        textColor,
                        palette.primary,
                      )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color textColor) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor.withValues(alpha: 0.5),
            letterSpacing: 0.5,
          ),
        ),
      );

  Widget _currencyTile(
    BuildContext context,
    String code,
    CurrencyProvider provider,
    Color textColor,
    Color accentColor,
  ) {
    final isSelected = code == widget.selectedCode;
    final isFav = provider.isFavorite(code);

    return ListTile(
      leading: Text(
        getCurrencyFlag(code),
        style: const TextStyle(fontSize: 28),
      ),
      title: Text(
        code,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isSelected ? accentColor : textColor,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        getCurrencyName(code),
        style: TextStyle(
          fontSize: 12,
          color: textColor.withValues(alpha: 0.55),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Icon(Icons.check_circle_rounded, color: accentColor, size: 20),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => provider.toggleFavorite(code),
            child: AnimatedSwitcher(
              duration: kAnimDurationFast,
              child: Icon(
                isFav ? Icons.star_rounded : Icons.star_border_rounded,
                key: ValueKey(isFav),
                color: isFav ? kWarning : Colors.grey.withValues(alpha: 0.5),
                size: 22,
              ),
            ),
          ),
        ],
      ),
      onTap: () => Navigator.pop(context, code),
    );
  }
}
