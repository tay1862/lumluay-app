import 'package:flutter_test/flutter_test.dart';
import 'package:lumluay_pos/core/database/app_database.dart';
import 'package:lumluay_pos/features/items/data/item_csv_service.dart';

Item _makeItem({
  String id = 'i1',
  String name = 'Coffee',
  String? sku = 'SKU001',
  String? barcode = '1234567890',
  double price = 50000,
  double cost = 20000,
  String? categoryId = 'c1',
  bool trackStock = true,
  bool soldByWeight = false,
}) {
  final now = DateTime(2024, 1, 1);
  return Item(
    id: id,
    storeId: 's1',
    categoryId: categoryId,
    name: name,
    sku: sku,
    barcode: barcode,
    price: price,
    cost: cost,
    trackStock: trackStock,
    soldByWeight: soldByWeight,
    active: true,
    createdAt: now,
    updatedAt: now,
  );
}

Category _makeCategory({String id = 'c1', String name = 'Beverages'}) {
  final now = DateTime(2024, 1, 1);
  return Category(
    id: id,
    storeId: 's1',
    name: name,
    color: '#FF0000',
    icon: 'cube',
    sortOrder: 0,
    active: true,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('ItemCsvService.exportItems', () {
    test('exports headers and item rows', () {
      final items = [_makeItem()];
      final categories = [_makeCategory()];
      final csv = ItemCsvService.exportItems(items, categories);

      expect(csv, contains('Name,SKU,Barcode,Price,Cost,Category'));
      expect(csv, contains('Coffee,SKU001,1234567890'));
      expect(csv, contains('Beverages'));
      expect(csv, contains('Yes')); // trackStock
    });

    test('exports empty category when categoryId is null', () {
      final items = [_makeItem(categoryId: null)];
      final csv = ItemCsvService.exportItems(items, []);
      final lines = csv.split('\n');
      expect(lines.length, greaterThanOrEqualTo(2));
      // Category column should be empty
      expect(lines[1], contains(',,'));
    });

    test('exports empty list produces only headers', () {
      final csv = ItemCsvService.exportItems([], []);
      final lines = csv.split('\n');
      expect(lines.length, 1); // just the header row
    });

    test('handles null sku and barcode', () {
      final items = [_makeItem(sku: null, barcode: null)];
      final csv = ItemCsvService.exportItems(items, []);
      expect(csv, contains('Coffee'));
    });

    test('exports sold by weight as Yes/No', () {
      final items = [
        _makeItem(soldByWeight: true, trackStock: false),
      ];
      final csv = ItemCsvService.exportItems(items, []);
      // Last two columns should be No,Yes
      expect(csv, contains('No,Yes'));
    });
  });

  group('ItemCsvService.parseItems', () {
    test('parses valid CSV', () {
      const csv = 'Name,SKU,Barcode,Price,Cost,Category,Track Stock,Sold by Weight\n'
          'Coffee,SKU001,1234567890,50000,20000,Beverages,Yes,No\n'
          'Tea,SKU002,,15000,5000,Beverages,No,No';
      final results = ItemCsvService.parseItems(csv);
      expect(results.length, 2);
      expect(results[0]['name'], 'Coffee');
      expect(results[0]['price'], 50000.0);
      expect(results[0]['trackStock'], true);
      expect(results[1]['name'], 'Tea');
      expect(results[1]['barcode'], '');
      expect(results[1]['trackStock'], false);
    });

    test('returns empty for header-only CSV', () {
      const csv = 'Name,SKU,Barcode,Price,Cost,Category,Track Stock,Sold by Weight';
      expect(ItemCsvService.parseItems(csv), isEmpty);
    });

    test('returns empty when Name column missing', () {
      const csv = 'SKU,Barcode,Price\nSKU001,123,100';
      expect(ItemCsvService.parseItems(csv), isEmpty);
    });

    test('skips rows with empty name', () {
      const csv = 'Name,Price\nCoffee,100\n,200\nTea,150';
      final results = ItemCsvService.parseItems(csv);
      expect(results.length, 2);
      expect(results[0]['name'], 'Coffee');
      expect(results[1]['name'], 'Tea');
    });

    test('handles missing optional columns gracefully', () {
      const csv = 'Name,Price\nCoffee,100';
      final results = ItemCsvService.parseItems(csv);
      expect(results.length, 1);
      expect(results[0]['name'], 'Coffee');
      expect(results[0]['price'], 100.0);
      expect(results[0]['sku'], isNull);
      expect(results[0]['trackStock'], false);
    });

    test('parses boolean values case-insensitively', () {
      const csv = 'Name,Track Stock,Sold by Weight\nA,YES,true\nB,1,FALSE\nC,no,0';
      final results = ItemCsvService.parseItems(csv);
      expect(results[0]['trackStock'], true);
      expect(results[0]['soldByWeight'], true);
      expect(results[1]['trackStock'], true);
      expect(results[1]['soldByWeight'], false);
      expect(results[2]['trackStock'], false);
      expect(results[2]['soldByWeight'], false);
    });

    test('handles non-numeric price gracefully', () {
      const csv = 'Name,Price\nCoffee,abc';
      final results = ItemCsvService.parseItems(csv);
      expect(results[0]['price'], 0.0);
    });
  });
}
