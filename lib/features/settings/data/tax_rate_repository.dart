import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class TaxRateRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  TaxRateRepository(this._db);

  Stream<List<TaxRate>> watchTaxRates(String storeId) {
    return (_db.select(_db.taxRates)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<TaxRate> create({
    required String storeId,
    required String name,
    required double rate,
    bool isInclusive = false,
    bool isDefault = false,
    String country = 'LA',
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.taxRates).insert(TaxRatesCompanion.insert(
          id: id,
          storeId: storeId,
          name: name,
          rate: rate,
          isInclusive: Value(isInclusive),
          isDefault: Value(isDefault),
          country: Value(country),
        ));
    return (await (_db.select(_db.taxRates)..where((t) => t.id.equals(id)))
        .getSingle());
  }

  Future<void> update({
    required String id,
    String? name,
    double? rate,
    bool? isInclusive,
    bool? isDefault,
  }) async {
    await (_db.update(_db.taxRates)..where((t) => t.id.equals(id))).write(
      TaxRatesCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        rate: rate != null ? Value(rate) : const Value.absent(),
        isInclusive:
            isInclusive != null ? Value(isInclusive) : const Value.absent(),
        isDefault:
            isDefault != null ? Value(isDefault) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(String id) async {
    // Remove item-tax associations first
    await (_db.delete(_db.itemTaxRates)
          ..where((t) => t.taxRateId.equals(id)))
        .go();
    await (_db.delete(_db.taxRates)..where((t) => t.id.equals(id))).go();
  }
}
