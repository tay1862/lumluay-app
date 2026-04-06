import 'dart:convert';

/// Supported currencies with symbols
class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  final int decimals;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    this.decimals = 0,
  });
}

class CurrencyService {
  static const currencies = <String, CurrencyInfo>{
    'LAK': CurrencyInfo(code: 'LAK', symbol: '₭', name: 'Lao Kip', decimals: 0),
    'THB': CurrencyInfo(code: 'THB', symbol: '฿', name: 'Thai Baht', decimals: 2),
    'USD': CurrencyInfo(code: 'USD', symbol: '\$', name: 'US Dollar', decimals: 2),
    'CNY': CurrencyInfo(code: 'CNY', symbol: '¥', name: 'Chinese Yuan', decimals: 2),
    'VND': CurrencyInfo(code: 'VND', symbol: '₫', name: 'Vietnamese Dong', decimals: 0),
  };

  static CurrencyInfo getCurrency(String code) {
    return currencies[code] ??
        CurrencyInfo(code: code, symbol: code, name: code);
  }

  /// Format amount with currency symbol
  static String format(double amount, String currencyCode) {
    final info = getCurrency(currencyCode);
    if (info.decimals == 0) {
      return '${info.symbol}${amount.toStringAsFixed(0)}';
    }
    return '${info.symbol}${amount.toStringAsFixed(info.decimals)}';
  }

  /// Convert amount from primary currency to target currency using exchange rates
  static double convert(
    double amount,
    String fromCurrency,
    String toCurrency,
    Map<String, double> exchangeRates,
  ) {
    if (fromCurrency == toCurrency) return amount;
    final rate = exchangeRates[toCurrency];
    if (rate == null || rate == 0) return amount;
    return amount * rate;
  }

  /// Parse exchange rates from JSON string stored in Stores table
  static Map<String, double> parseExchangeRates(String json) {
    if (json.isEmpty || json == '{}') return {};
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (_) {
      return {};
    }
  }

  /// Parse secondary currencies from JSON array string
  static List<String> parseSecondaryCurrencies(String json) {
    if (json.isEmpty || json == '[]') return [];
    try {
      final list = jsonDecode(json) as List;
      return list.cast<String>();
    } catch (_) {
      return [];
    }
  }
}
