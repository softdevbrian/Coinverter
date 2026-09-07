/// Represents a single currency conversion result, stored in history.
class ConversionResult {
  final String fromCurrency;
  final String toCurrency;
  final double inputAmount;
  final double convertedAmount;
  final double exchangeRate;
  final DateTime timestamp;

  ConversionResult({
    required this.fromCurrency,
    required this.toCurrency,
    required this.inputAmount,
    required this.convertedAmount,
    required this.exchangeRate,
    required this.timestamp,
  });

  /// Serialise to JSON for SharedPreferences storage.
  Map<String, dynamic> toJson() => {
        'fromCurrency': fromCurrency,
        'toCurrency': toCurrency,
        'inputAmount': inputAmount,
        'convertedAmount': convertedAmount,
        'exchangeRate': exchangeRate,
        'timestamp': timestamp.toIso8601String(),
      };

  /// Deserialise from JSON.
  factory ConversionResult.fromJson(Map<String, dynamic> json) =>
      ConversionResult(
        fromCurrency: json['fromCurrency'] as String,
        toCurrency: json['toCurrency'] as String,
        inputAmount: (json['inputAmount'] as num).toDouble(),
        convertedAmount: (json['convertedAmount'] as num).toDouble(),
        exchangeRate: (json['exchangeRate'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
