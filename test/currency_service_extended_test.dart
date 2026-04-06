import 'package:flutter_test/flutter_test.dart';
import 'package:lumluay_pos/core/constants/currency_service.dart';

// Additional currency service tests beyond the basics
void main() {
  group('CurrencyService.format — edge cases', () {
    test('formats zero correctly for LAK', () {
      expect(CurrencyService.format(0, 'LAK'), '₭0');
    });

    test('formats zero correctly for USD', () {
      expect(CurrencyService.format(0, 'USD'), '\$0.00');
    });

    test('formats large amounts without overflow', () {
      final result = CurrencyService.format(999999999.0, 'LAK');
      expect(result, '₭999999999');
    });

    test('rounds to correct decimal places for THB', () {
      expect(CurrencyService.format(100.456, 'THB'), '฿100.46');
    });

    test('unknown currency uses code as symbol', () {
      expect(CurrencyService.format(100, 'XYZ'), 'XYZ100');
    });

    test('negative amounts are formatted correctly', () {
      expect(CurrencyService.format(-5000, 'LAK'), '₭-5000');
    });
  });

  group('CurrencyService.convert', () {
    test('same currency returns same amount', () {
      expect(
        CurrencyService.convert(1000, 'LAK', 'LAK', {'THB': 0.002}),
        1000,
      );
    });

    test('converts with valid exchange rate', () {
      final result = CurrencyService.convert(
        100000,
        'LAK',
        'THB',
        {'THB': 0.002},
      );
      expect(result, closeTo(200, 0.01));
    });

    test('returns original if target rate not found', () {
      expect(
        CurrencyService.convert(1000, 'LAK', 'EUR', {'THB': 0.002}),
        1000,
      );
    });

    test('returns original if rate is zero', () {
      expect(
        CurrencyService.convert(1000, 'LAK', 'THB', {'THB': 0.0}),
        1000,
      );
    });
  });

  group('CurrencyService.parseExchangeRates', () {
    test('parses valid JSON', () {
      final rates = CurrencyService.parseExchangeRates('{"THB":0.002,"USD":0.00005}');
      expect(rates['THB'], 0.002);
      expect(rates['USD'], 0.00005);
    });

    test('returns empty map for empty string', () {
      expect(CurrencyService.parseExchangeRates(''), isEmpty);
    });

    test('returns empty map for empty JSON object', () {
      expect(CurrencyService.parseExchangeRates('{}'), isEmpty);
    });

    test('returns empty map for invalid JSON', () {
      expect(CurrencyService.parseExchangeRates('not json'), isEmpty);
    });
  });

  group('CurrencyService.getCurrency', () {
    test('returns known currencies', () {
      expect(CurrencyService.getCurrency('LAK').symbol, '₭');
      expect(CurrencyService.getCurrency('THB').symbol, '฿');
      expect(CurrencyService.getCurrency('USD').symbol, '\$');
      expect(CurrencyService.getCurrency('CNY').symbol, '¥');
      expect(CurrencyService.getCurrency('VND').symbol, '₫');
    });

    test('LAK has 0 decimals', () {
      expect(CurrencyService.getCurrency('LAK').decimals, 0);
    });

    test('USD has 2 decimals', () {
      expect(CurrencyService.getCurrency('USD').decimals, 2);
    });

    test('VND has 0 decimals', () {
      expect(CurrencyService.getCurrency('VND').decimals, 0);
    });

    test('unknown currency returns fallback', () {
      final c = CurrencyService.getCurrency('UNKNOWN');
      expect(c.code, 'UNKNOWN');
      expect(c.symbol, 'UNKNOWN');
    });
  });
}
