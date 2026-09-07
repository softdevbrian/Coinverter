/// Full currency data: code → {name, symbol, flag}.
///
/// Contains 40 of the most-used world currencies for a polished curated
/// experience, while the live API will supply rates for all of them.
const Map<String, Map<String, String>> kCurrencyMeta = {
  'USD': {'name': 'US Dollar', 'symbol': '\$', 'flag': '🇺🇸'},
  'EUR': {'name': 'Euro', 'symbol': '€', 'flag': '🇪🇺'},
  'GBP': {'name': 'British Pound', 'symbol': '£', 'flag': '🇬🇧'},
  'KES': {'name': 'Kenyan Shilling', 'symbol': 'KSh', 'flag': '🇰🇪'},
  'JPY': {'name': 'Japanese Yen', 'symbol': '¥', 'flag': '🇯🇵'},
  'CNY': {'name': 'Chinese Yuan', 'symbol': '¥', 'flag': '🇨🇳'},
  'INR': {'name': 'Indian Rupee', 'symbol': '₹', 'flag': '🇮🇳'},
  'AUD': {'name': 'Australian Dollar', 'symbol': 'A\$', 'flag': '🇦🇺'},
  'CAD': {'name': 'Canadian Dollar', 'symbol': 'C\$', 'flag': '🇨🇦'},
  'CHF': {'name': 'Swiss Franc', 'symbol': 'Fr', 'flag': '🇨🇭'},
  'KRW': {'name': 'South Korean Won', 'symbol': '₩', 'flag': '🇰🇷'},
  'SGD': {'name': 'Singapore Dollar', 'symbol': 'S\$', 'flag': '🇸🇬'},
  'MXN': {'name': 'Mexican Peso', 'symbol': '\$', 'flag': '🇲🇽'},
  'BRL': {'name': 'Brazilian Real', 'symbol': 'R\$', 'flag': '🇧🇷'},
  'ZAR': {'name': 'South African Rand', 'symbol': 'R', 'flag': '🇿🇦'},
  'NGN': {'name': 'Nigerian Naira', 'symbol': '₦', 'flag': '🇳🇬'},
  'GHS': {'name': 'Ghanaian Cedi', 'symbol': 'GH₵', 'flag': '🇬🇭'},
  'UGX': {'name': 'Ugandan Shilling', 'symbol': 'USh', 'flag': '🇺🇬'},
  'TZS': {'name': 'Tanzanian Shilling', 'symbol': 'TSh', 'flag': '🇹🇿'},
  'RWF': {'name': 'Rwandan Franc', 'symbol': 'Fr', 'flag': '🇷🇼'},
  'ETB': {'name': 'Ethiopian Birr', 'symbol': 'Br', 'flag': '🇪🇹'},
  'EGP': {'name': 'Egyptian Pound', 'symbol': '£', 'flag': '🇪🇬'},
  'AED': {'name': 'UAE Dirham', 'symbol': 'د.إ', 'flag': '🇦🇪'},
  'SAR': {'name': 'Saudi Riyal', 'symbol': '﷼', 'flag': '🇸🇦'},
  'TRY': {'name': 'Turkish Lira', 'symbol': '₺', 'flag': '🇹🇷'},
  'RUB': {'name': 'Russian Ruble', 'symbol': '₽', 'flag': '🇷🇺'},
  'SEK': {'name': 'Swedish Krona', 'symbol': 'kr', 'flag': '🇸🇪'},
  'NOK': {'name': 'Norwegian Krone', 'symbol': 'kr', 'flag': '🇳🇴'},
  'DKK': {'name': 'Danish Krone', 'symbol': 'kr', 'flag': '🇩🇰'},
  'PLN': {'name': 'Polish Złoty', 'symbol': 'zł', 'flag': '🇵🇱'},
  'HUF': {'name': 'Hungarian Forint', 'symbol': 'Ft', 'flag': '🇭🇺'},
  'CZK': {'name': 'Czech Koruna', 'symbol': 'Kč', 'flag': '🇨🇿'},
  'THB': {'name': 'Thai Baht', 'symbol': '฿', 'flag': '🇹🇭'},
  'MYR': {'name': 'Malaysian Ringgit', 'symbol': 'RM', 'flag': '🇲🇾'},
  'IDR': {'name': 'Indonesian Rupiah', 'symbol': 'Rp', 'flag': '🇮🇩'},
  'PHP': {'name': 'Philippine Peso', 'symbol': '₱', 'flag': '🇵🇭'},
  'VND': {'name': 'Vietnamese Dong', 'symbol': '₫', 'flag': '🇻🇳'},
  'PKR': {'name': 'Pakistani Rupee', 'symbol': '₨', 'flag': '🇵🇰'},
  'BDT': {'name': 'Bangladeshi Taka', 'symbol': '৳', 'flag': '🇧🇩'},
  'NZD': {'name': 'New Zealand Dollar', 'symbol': 'NZ\$', 'flag': '🇳🇿'},
};

/// Fallback hardcoded rates (USD base) used when offline and no cache exists.
const Map<String, double> kFallbackRates = {
  'USD': 1.0,
  'EUR': 0.92,
  'GBP': 0.79,
  'KES': 129.28,
  'JPY': 149.50,
  'CNY': 7.24,
  'INR': 83.12,
  'AUD': 1.53,
  'CAD': 1.36,
  'CHF': 0.90,
  'KRW': 1325.0,
  'SGD': 1.34,
  'MXN': 17.15,
  'BRL': 4.97,
  'ZAR': 18.63,
  'NGN': 1540.0,
  'GHS': 12.5,
  'UGX': 3750.0,
  'TZS': 2530.0,
  'RWF': 1280.0,
  'ETB': 56.5,
  'EGP': 30.9,
  'AED': 3.67,
  'SAR': 3.75,
  'TRY': 32.1,
  'RUB': 90.5,
  'SEK': 10.41,
  'NOK': 10.55,
  'DKK': 6.89,
  'PLN': 4.02,
  'HUF': 358.0,
  'CZK': 22.8,
  'THB': 35.1,
  'MYR': 4.68,
  'IDR': 15600.0,
  'PHP': 56.2,
  'VND': 24450.0,
  'PKR': 278.0,
  'BDT': 110.0,
  'NZD': 1.63,
};

/// Returns the currency name for a given code.
String getCurrencyName(String code) =>
    kCurrencyMeta[code]?['name'] ?? code;

/// Returns the currency symbol for a given code.
String getCurrencySymbol(String code) =>
    kCurrencyMeta[code]?['symbol'] ?? code;

/// Returns the flag emoji for a given code.
String getCurrencyFlag(String code) =>
    kCurrencyMeta[code]?['flag'] ?? '🏳';

/// Returns all supported currency codes, sorted alphabetically with
/// USD and KES first.
List<String> getSortedCurrencyCodes() {
  final codes = kCurrencyMeta.keys.toList();
  codes.remove('USD');
  codes.remove('KES');
  codes.sort();
  return ['USD', 'KES', ...codes];
}
