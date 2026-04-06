import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';

class ItemRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  ItemRepository(this._db);

  Stream<List<Item>> watchItems(String storeId, {String? categoryId}) {
    final query = _db.select(_db.items)
      ..where((t) => t.storeId.equals(storeId) & t.active.equals(true));
    if (categoryId != null) {
      query.where((t) => t.categoryId.equals(categoryId));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.watch();
  }

  Future<List<Item>> getItems(String storeId, {String? categoryId}) async {
    final query = _db.select(_db.items)
      ..where((t) => t.storeId.equals(storeId) & t.active.equals(true));
    if (categoryId != null) {
      query.where((t) => t.categoryId.equals(categoryId));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.get();
  }

  Future<Item?> getById(String id) async {
    return (_db.select(_db.items)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<Item?> getByBarcode(String barcode, String storeId) async {
    return (_db.select(_db.items)
          ..where((t) =>
              t.barcode.equals(barcode) &
              t.storeId.equals(storeId) &
              t.active.equals(true)))
        .getSingleOrNull();
  }

  Future<List<Item>> search(String storeId, String query) async {
    final escaped = _escapeLike(query);
    return (_db.select(_db.items)
          ..where((t) =>
              t.storeId.equals(storeId) &
              t.active.equals(true) &
              (t.name.like('%$escaped%') |
                  t.sku.like('%$escaped%') |
                  t.barcode.like('%$escaped%')))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<Result<Item>> create({
    required String storeId,
    required String name,
    String? categoryId,
    String? sku,
    String? barcode,
    double price = 0.0,
    double cost = 0.0,
    bool trackStock = false,
    bool soldByWeight = false,
    String? imagePath,
  }) async {
    try {
      final id = _uuid.v4();
      final companion = ItemsCompanion.insert(
        id: id,
        storeId: storeId,
        name: name,
        categoryId: Value(categoryId),
        sku: Value(sku),
        barcode: Value(barcode),
        price: Value(price),
        cost: Value(cost),
        trackStock: Value(trackStock),
        soldByWeight: Value(soldByWeight),
        imagePath: Value(imagePath),
      );
      await _db.into(_db.items).insert(companion);
      final created = await getById(id);
      return Success(created!);
    } catch (e, st) {
      AppLogger.error('Failed to create item', e, st);
      return Failure(
          DatabaseException(message: 'Failed to create item', originalError: e));
    }
  }

  Future<Result<void>> update({
    required String id,
    String? name,
    String? categoryId,
    String? sku,
    String? barcode,
    double? price,
    double? cost,
    bool? trackStock,
    bool? soldByWeight,
    String? imagePath,
    bool? active,
  }) async {
    try {
      await (_db.update(_db.items)..where((t) => t.id.equals(id))).write(
        ItemsCompanion(
          name: name != null ? Value(name) : const Value.absent(),
          categoryId:
              categoryId != null ? Value(categoryId) : const Value.absent(),
          sku: sku != null ? Value(sku) : const Value.absent(),
          barcode: barcode != null ? Value(barcode) : const Value.absent(),
          price: price != null ? Value(price) : const Value.absent(),
          cost: cost != null ? Value(cost) : const Value.absent(),
          trackStock:
              trackStock != null ? Value(trackStock) : const Value.absent(),
          soldByWeight:
              soldByWeight != null ? Value(soldByWeight) : const Value.absent(),
          imagePath:
              imagePath != null ? Value(imagePath) : const Value.absent(),
          active: active != null ? Value(active) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to update item', e, st);
      return Failure(
          DatabaseException(message: 'Failed to update item', originalError: e));
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      await (_db.update(_db.items)..where((t) => t.id.equals(id))).write(
        ItemsCompanion(
          active: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to delete item', e, st);
      return Failure(
          DatabaseException(message: 'Failed to delete item', originalError: e));
    }
  }

  Future<int> countByCategory(String categoryId) async {
    final query = _db.selectOnly(_db.items)
      ..addColumns([_db.items.id.count()])
      ..where(
          _db.items.categoryId.equals(categoryId) & _db.items.active.equals(true));
    final result = await query.getSingle();
    return result.read(_db.items.id.count()) ?? 0;
  }

  static String _escapeLike(String input) =>
      input.replaceAll('\\', '\\\\').replaceAll('%', '\\%').replaceAll('_', '\\_');
}
