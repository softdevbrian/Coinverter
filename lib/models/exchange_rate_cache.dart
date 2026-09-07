/// Holds a snapshot of exchange rates with a timestamp and source flag.
class ExchangeRateCache {
  final Map<String, double> rates;
  final DateTime lastUpdated;
  final bool isFromApi; // true = freshly fetched; false = hardcoded fallback

  const ExchangeRateCache({
    required this.rates,
    required this.lastUpdated,
    this.isFromApi = true,
  });

  /// How long ago the cache was last updated, as a human-readable string.
  String get ageDescription {
    final diff = DateTime.now().difference(lastUpdated);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  bool get isStale => DateTime.now().difference(lastUpdated).inHours >= 1;
}
