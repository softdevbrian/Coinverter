/// Represents a currency with its metadata.
class Currency {
  final String code;    // e.g. "USD"
  final String name;    // e.g. "United States Dollar"
  final String symbol;  // e.g. "$"
  final String flag;    // e.g. "🇺🇸"
  bool isFavorite;

  Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
    this.isFavorite = false,
  });

  @override
  bool operator ==(Object other) => other is Currency && other.code == code;

  @override
  int get hashCode => code.hashCode;
}
