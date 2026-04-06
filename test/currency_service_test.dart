import 'package:flutter_test/flutter_test.dart';
import 'package:lumluay_pos/core/constants/currency_service.dart';

void main() {
  group('CurrencyService', () {
    group('format', () {
      test('formats LAK with no decimals', () {
        expect(CurrencyService.format(50000, 'LAK'), '₭50000');
      });

      test('formats THB with 2 decimals', () {
        expect(CurrencyService.format(150.5, 'THB'), '฿150.50');
      });

      test('formats USD with 2 decimals', () {
        expect(CurrencyService.format(9.99, 'USD'), '\$9.99');
      });

      test('formats VND with no decimals', () {
        expect(CurrencyService.format(100000, 'VND'), '₫100000');
      });

      test('formats CNY with 2 decimals', () {
        expect(CurrencyService.format(88.1, 'CNY'), '¥88.10');
      });

      test('formats zero correctly', () {
        expect(CurrencyService.format(0, 'LAK'), '₭0');
        expect(CurrencyService.format(0, 'USD'), '\$0.00');
      });

      test('handles unknown currency code', () {
        expect(CurrencyService.format(100, 'XYZ'), 'XYZ100');
      });
    });

    group('convert', () {
      test('returns same amount for same currency', () {
        expect(
          CurrencyService.convert(1000, 'LAK', 'LAK', {'THB': 0.002}),
          1000,
        );
      });

      test('converts LAK to THB', () {
        final result = CurrencyService.convert(
          20000,
          'LAK',
          'THB',
          {'THB': 0.002},
        );
        expect(result, closeTo(40, 0.01));
      });

      test('returns original amount when rate missing', () {
        expect(
          CurrencyService.convert(1000, 'LAK', 'EUR', {'THB': 0.002}),
          1000,
        );
      });
    });

    group('parseExchangeRates', () {
      test('parses valid JSON', () {
        final rates =
            CurrencyService.parseExchangeRates('{"THB":0.002,"USD":0.00005}');
        expect(rates, {'THB': 0.002, 'USD': 0.00005});
      });

      test('returns empty map for empty string', () {
        expect(CurrencyService.parseExchangeRates(''), isEmpty);
      });

      test('returns empty map for empty JSON', () {
        expect(CurrencyService.parseExchangeRates('{}'), isEmpty);
      });

      test('returns empty map for invalid JSON', () {
        expect(CurrencyService.parseExchangeRates('not json'), isEmpty);
      });
    });

    group('parseSecondaryCurrencies', () {
      test('parses valid JSON array', () {
        expect(
          CurrencyService.parseSecondaryCurrencies('["THB","USD"]'),
          ['THB', 'USD'],
        );
      });

      test('returns empty list for empty input', () {
        expect(CurrencyService.parseSecondaryCurrencies(''), isEmpty);
        expect(CurrencyService.parseSecondaryCurrencies('[]'), isEmpty);
      });

      test('returns empty list for invalid JSON', () {
        expect(CurrencyService.parseSecondaryCurrencies('bad'), isEmpty);
      });
    });

    group('getCurrency', () {
      test('returns known currency', () {
        final info = CurrencyService.getCurrency('LAK');
        expect(info.symbol, '₭');
        expect(info.decimals, 0);
      });

      test('returns fallback for unknown currency', () {
        final info = CurrencyService.getCurrency('ABC');
        expect(info.code, 'ABC');
        expect(info.symbol, 'ABC');
      });
    });
  });
}
