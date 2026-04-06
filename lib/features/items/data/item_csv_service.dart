import 'package:csv/csv.dart';

import '../../../core/database/app_database.dart';

class ItemCsvService {
  static const _headers = [
    'Name',
    'SKU',
    'Barcode',
    'Price',
    'Cost',
    'Category',
    'Track Stock',
    'Sold by Weight',
  ];

  /// Export items to CSV string
  static String exportItems(List<Item> items, List<Category> categories) {
    final catMap = {for (final c in categories) c.id: c.name};
    final rows = <List<dynamic>>[
      _headers,
      ...items.map((item) => [
            item.name,
            item.sku ?? '',
            item.barcode ?? '',
            item.price,
            item.cost,
            item.categoryId != null ? (catMap[item.categoryId] ?? '') : '',
            item.trackStock ? 'Yes' : 'No',
            item.soldByWeight ? 'Yes' : 'No',
          ]),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  /// Parse CSV string into item field maps.
  /// Returns list of maps with keys matching Item fields.
  /// The caller is responsible for category lookup and creation.
  static List<Map<String, dynamic>> parseItems(String csvContent) {
    final rows =
        const CsvToListConverter(eol: '\n').convert(csvContent.trim());
    if (rows.length < 2) return [];

    // Find column indices from header row
    final headerRow =
        rows.first.map((h) => h.toString().trim().toLowerCase()).toList();

    int col(String name) => headerRow.indexOf(name.toLowerCase());

    final nameIdx = col('name');
    final skuIdx = col('sku');
    final barcodeIdx = col('barcode');
    final priceIdx = col('price');
    final costIdx = col('cost');
    final categoryIdx = col('category');
    final trackStockIdx = col('track stock');
    final soldByWeightIdx = col('sold by weight');

    if (nameIdx < 0) return []; // Name is required

    final results = <Map<String, dynamic>>[];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;
      final name = _safeGet(row, nameIdx)?.toString().trim() ?? '';
      if (name.isEmpty) continue;

      results.add({
        'name': name,
        'sku': _safeGet(row, skuIdx)?.toString().trim(),
        'barcode': _safeGet(row, barcodeIdx)?.toString().trim(),
        'price': _parseDouble(_safeGet(row, priceIdx)),
        'cost': _parseDouble(_safeGet(row, costIdx)),
        'categoryName': _safeGet(row, categoryIdx)?.toString().trim(),
        'trackStock': _parseBool(_safeGet(row, trackStockIdx)),
        'soldByWeight': _parseBool(_safeGet(row, soldByWeightIdx)),
      });
    }
    return results;
  }

  static dynamic _safeGet(List<dynamic> row, int index) {
    if (index < 0 || index >= row.length) return null;
    return row[index];
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim()) ?? 0.0;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    final s = value.toString().trim().toLowerCase();
    return s == 'yes' || s == 'true' || s == '1';
  }
}
