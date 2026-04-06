import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class StoreRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  StoreRepository(this._db);

  /// Watch all stores
  Stream<List<Store>> watchStores() {
    return (_db.select(_db.stores)
          ..orderBy([(s) => OrderingTerm.asc(s.name)]))
        .watch();
  }

  /// Get all stores
  Future<List<Store>> getStores() async {
    return (_db.select(_db.stores)
          ..orderBy([(s) => OrderingTerm.asc(s.name)]))
        .get();
  }

  Future<Store?> getStore(String storeId) async {
    return (_db.select(_db.stores)..where((s) => s.id.equals(storeId)))
        .getSingleOrNull();
  }

  Stream<Store?> watchStore(String storeId) {
    return (_db.select(_db.stores)..where((s) => s.id.equals(storeId)))
        .watchSingleOrNull();
  }

  Future<void> updateStore({
    required String id,
    String? name,
    String? address,
    String? phone,
    String? currency,
    String? timezone,
    String? logo,
    String? secondaryCurrencies,
    String? exchangeRates,
  }) async {
    await (_db.update(_db.stores)..where((s) => s.id.equals(id))).write(
      StoresCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        address: address != null ? Value(address) : const Value.absent(),
        phone: phone != null ? Value(phone) : const Value.absent(),
        currency: currency != null ? Value(currency) : const Value.absent(),
        timezone: timezone != null ? Value(timezone) : const Value.absent(),
        logo: logo != null ? Value(logo) : const Value.absent(),
        secondaryCurrencies: secondaryCurrencies != null
            ? Value(secondaryCurrencies)
            : const Value.absent(),
        exchangeRates: exchangeRates != null
            ? Value(exchangeRates)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Create a new store
  Future<Store> createStore({
    required String name,
    String address = '',
    String phone = '',
    String currency = 'LAK',
    String timezone = 'Asia/Vientiane',
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.stores).insert(StoresCompanion.insert(
          id: id,
          name: name,
          address: Value(address),
          phone: Value(phone),
          currency: Value(currency),
          timezone: Value(timezone),
        ));
    return (await getStore(id))!;
  }

  /// Delete a store
  Future<void> deleteStore(String id) async {
    await (_db.delete(_db.stores)..where((s) => s.id.equals(id))).go();
  }
}
