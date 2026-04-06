import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

/// Result of tax calculation for a single cart item line.
class TaxLineResult {
  final String taxRateId;
  final String taxRateName;
  final double rate;
  final bool isInclusive;
  final double taxAmount;

  const TaxLineResult({
    required this.taxRateId,
    required this.taxRateName,
    required this.rate,
    required this.isInclusive,
    required this.taxAmount,
  });
}

/// Aggregated tax breakdown for a full cart.
class TaxBreakdown {
  final Map<String, TaxLineResult> byRate;
  final double totalTax;
  final double totalInclusive;
  final double totalExclusive;

  const TaxBreakdown({
    required this.byRate,
    required this.totalTax,
    required this.totalInclusive,
    required this.totalExclusive,
  });
}

/// Tax calculation engine supporting multiple taxes per item,
/// inclusive/exclusive pricing, and per-country tax rules.
class TaxService {
  final AppDatabase _db;

  TaxService(this._db);

  /// Get all tax rates applied to an item (via ItemTaxRates junction).
  Future<List<TaxRate>> getTaxRatesForItem(String itemId) async {
    final junctions = await (_db.select(_db.itemTaxRates)
          ..where((t) => t.itemId.equals(itemId)))
        .get();
    if (junctions.isEmpty) return [];

    final taxRateIds = junctions.map((j) => j.taxRateId).toList();
    return (_db.select(_db.taxRates)
          ..where((t) => t.id.isIn(taxRateIds)))
        .get();
  }

  /// Get default tax rates for a store (applied when no item-specific tax).
  Future<List<TaxRate>> getDefaultTaxRates(String storeId) async {
    return (_db.select(_db.taxRates)
          ..where(
              (t) => t.storeId.equals(storeId) & t.isDefault.equals(true)))
        .get();
  }

  /// Calculate tax for a single item line.
  /// [lineAmount] = (unitPrice + modifierTotal - discount) * quantity
  List<TaxLineResult> calculateItemTax(
    double lineAmount,
    List<TaxRate> taxRates,
  ) {
    final results = <TaxLineResult>[];
    for (final rate in taxRates) {
      double taxAmount;
      if (rate.isInclusive) {
        // Tax-inclusive: price already includes tax
        // tax = amount - (amount / (1 + rate))
        taxAmount = lineAmount - (lineAmount / (1 + rate.rate / 100));
      } else {
        // Tax-exclusive: tax added on top
        taxAmount = lineAmount * (rate.rate / 100);
      }
      results.add(TaxLineResult(
        taxRateId: rate.id,
        taxRateName: rate.name,
        rate: rate.rate,
        isInclusive: rate.isInclusive,
        taxAmount: _round(taxAmount),
      ));
    }
    return results;
  }

  /// Calculate full cart tax breakdown.
  /// Returns aggregate by tax rate + totals.
  Future<TaxBreakdown> calculateCartTax({
    required String storeId,
    required List<CartItemTaxInput> items,
  }) async {
    final defaultRates = await getDefaultTaxRates(storeId);
    final byRate = <String, TaxLineResult>{};
    double totalInclusive = 0;
    double totalExclusive = 0;

    for (final item in items) {
      // Get item-specific tax rates, fallback to store defaults
      var taxRates = await getTaxRatesForItem(item.itemId);
      if (taxRates.isEmpty) {
        taxRates = defaultRates;
      }

      final lineTaxes = calculateItemTax(item.lineAmount, taxRates);
      for (final lt in lineTaxes) {
        if (byRate.containsKey(lt.taxRateId)) {
          final existing = byRate[lt.taxRateId]!;
          byRate[lt.taxRateId] = TaxLineResult(
            taxRateId: lt.taxRateId,
            taxRateName: lt.taxRateName,
            rate: lt.rate,
            isInclusive: lt.isInclusive,
            taxAmount: _round(existing.taxAmount + lt.taxAmount),
          );
        } else {
          byRate[lt.taxRateId] = lt;
        }

        if (lt.isInclusive) {
          totalInclusive += lt.taxAmount;
        } else {
          totalExclusive += lt.taxAmount;
        }
      }
    }

    return TaxBreakdown(
      byRate: byRate,
      totalTax: _round(totalInclusive + totalExclusive),
      totalInclusive: _round(totalInclusive),
      totalExclusive: _round(totalExclusive),
    );
  }

  /// Link a tax rate to an item
  Future<void> assignTaxToItem(String itemId, String taxRateId) async {
    await _db.into(_db.itemTaxRates).insertOnConflictUpdate(
          ItemTaxRatesCompanion.insert(
            itemId: itemId,
            taxRateId: taxRateId,
          ),
        );
  }

  /// Remove a tax rate from an item
  Future<void> removeTaxFromItem(String itemId, String taxRateId) async {
    await (_db.delete(_db.itemTaxRates)
          ..where(
              (t) => t.itemId.equals(itemId) & t.taxRateId.equals(taxRateId)))
        .go();
  }

  /// Get all tax rate IDs assigned to an item
  Future<List<String>> getItemTaxRateIds(String itemId) async {
    final junctions = await (_db.select(_db.itemTaxRates)
          ..where((t) => t.itemId.equals(itemId)))
        .get();
    return junctions.map((j) => j.taxRateId).toList();
  }

  double _round(double val) => (val * 100).roundToDouble() / 100;
}

/// Input for cart tax calculation
class CartItemTaxInput {
  final String itemId;
  final double lineAmount;

  const CartItemTaxInput({
    required this.itemId,
    required this.lineAmount,
  });
}
