import 'package:intl/intl.dart';

/// Formats a numeric amount for display — abbreviated for large values,
/// or full with comma separators.
class CurrencyFormatter {
  /// Abbreviated format: 1,234,567 → "1.23 M"
  static String abbreviated(double value, String currencyCode,
      {int decimals = 2}) {
    if (value == 0) return '0.${'0' * decimals}';

    final isWholeUnit =
        currencyCode == 'JPY' || currencyCode == 'KRW' ||
        currencyCode == 'IDR' || currencyCode == 'VND' ||
        currencyCode == 'HUF' || currencyCode == 'UGX' ||
        currencyCode == 'TZS' || currencyCode == 'RWF';
    final d = isWholeUnit ? 0 : decimals;

    if (value >= 1e15) return '${(value / 1e15).toStringAsFixed(d)} Q';
    if (value >= 1e12) return '${(value / 1e12).toStringAsFixed(d)} T';
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(d)} B';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(d)} M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(d)} K';
    return isWholeUnit
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(decimals);
  }

  /// Full format with comma separators: 1234567.89 → "1,234,567.89"
  static String full(double value, String currencyCode, {int decimals = 2}) {
    if (value == 0) return '0.${'0' * decimals}';
    final isWholeUnit =
        currencyCode == 'JPY' || currencyCode == 'KRW' ||
        currencyCode == 'IDR' || currencyCode == 'VND' ||
        currencyCode == 'HUF' || currencyCode == 'UGX' ||
        currencyCode == 'TZS' || currencyCode == 'RWF';
    final pattern =
        isWholeUnit ? '#,##0' : '#,##0.${'0' * decimals}';
    return NumberFormat(pattern).format(value);
  }

  /// Formats the exchange rate for display.
  /// e.g. "1 USD = 129.28 KES"
  static String rateDisplay(
      String from, String to, double rate, {int decimals = 4}) {
    final formatted = rate < 1
        ? rate.toStringAsFixed(decimals)
        : rate.toStringAsFixed(2);
    return '1 $from = $formatted $to';
  }

  /// Formats a DateTime as a relative or absolute string.
  static String formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return DateFormat.jm().format(dt); // e.g. "3:45 PM"
    } else if (diff.inDays == 1) {
      return 'Yesterday ${DateFormat.jm().format(dt)}';
    } else if (diff.inDays < 7) {
      return DateFormat('EEE, h:mm a').format(dt); // e.g. "Mon, 3:45 PM"
    } else {
      return DateFormat('MMM d, yyyy').format(dt);
    }
  }

  /// Groups a list of conversion results by date label.
  static String groupLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMMM d, yyyy').format(dt);
  }
}

/// Custom TextInputFormatter logic — used externally in a widget.
String formatInputText(String raw) {
  // Strip non-numeric except decimal
  String text = raw.replaceAll(RegExp(r'[^\d.]'), '');
  // Keep only first decimal point
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
  return '$integer$decimal';
}
