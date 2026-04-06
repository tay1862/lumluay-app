import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';

class VariantRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  VariantRepository(this._db);

  // ── Variant Groups ──

  Stream<List<VariantGroup>> watchGroups(String itemId) {
    return (_db.select(_db.variantGroups)
          ..where((g) => g.itemId.equals(itemId))
          ..orderBy([(g) => OrderingTerm.asc(g.sortOrder)]))
        .watch();
  }

  Future<List<VariantGroup>> getGroups(String itemId) async {
    return (_db.select(_db.variantGroups)
          ..where((g) => g.itemId.equals(itemId))
          ..orderBy([(g) => OrderingTerm.asc(g.sortOrder)]))
        .get();
  }

  Future<Result<VariantGroup>> createGroup({
    required String itemId,
    required String name,
    int sortOrder = 0,
  }) async {
    try {
      final id = _uuid.v4();
      await _db.into(_db.variantGroups).insert(VariantGroupsCompanion.insert(
            id: id,
            itemId: itemId,
            name: name,
            sortOrder: Value(sortOrder),
          ));
      final created = await (_db.select(_db.variantGroups)
            ..where((g) => g.id.equals(id)))
          .getSingle();
      return Success(created);
    } catch (e, st) {
      AppLogger.error('Failed to create variant group', e, st);
      return Failure(DatabaseException(message: e.toString()));
    }
  }

  Future<Result<void>> deleteGroup(String groupId) async {
    try {
      // Delete variants in group first
      await (_db.delete(_db.variants)
            ..where((v) => v.variantGroupId.equals(groupId)))
          .go();
      await (_db.delete(_db.variantGroups)
            ..where((g) => g.id.equals(groupId)))
          .go();
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to delete variant group', e, st);
      return Failure(DatabaseException(message: e.toString()));
    }
  }

  // ── Variants ──

  Stream<List<Variant>> watchVariants(String groupId) {
    return (_db.select(_db.variants)
          ..where((v) => v.variantGroupId.equals(groupId))
          ..orderBy([(v) => OrderingTerm.asc(v.name)]))
        .watch();
  }

  Future<List<Variant>> getVariantsForItem(String itemId) async {
    return (_db.select(_db.variants)
          ..where((v) => v.itemId.equals(itemId))
          ..orderBy([(v) => OrderingTerm.asc(v.name)]))
        .get();
  }

  Future<Variant?> getVariantByBarcode(String barcode, String itemId) async {
    return (_db.select(_db.variants)
          ..where(
              (v) => v.barcode.equals(barcode) & v.itemId.equals(itemId)))
        .getSingleOrNull();
  }

  /// Lookup any variant by barcode (across all items) for scanner use
  Future<Variant?> findVariantByBarcode(String barcode) async {
    return (_db.select(_db.variants)
          ..where((v) => v.barcode.equals(barcode)))
        .getSingleOrNull();
  }

  Future<Result<Variant>> createVariant({
    required String variantGroupId,
    required String itemId,
    required String name,
    String? sku,
    String? barcode,
    double price = 0.0,
    double cost = 0.0,
  }) async {
    try {
      final id = _uuid.v4();
      await _db.into(_db.variants).insert(VariantsCompanion.insert(
            id: id,
            variantGroupId: variantGroupId,
            itemId: itemId,
            name: name,
            sku: Value(sku),
            barcode: Value(barcode),
            price: Value(price),
            cost: Value(cost),
          ));
      final created =
          await (_db.select(_db.variants)..where((v) => v.id.equals(id)))
              .getSingle();
      return Success(created);
    } catch (e, st) {
      AppLogger.error('Failed to create variant', e, st);
      return Failure(DatabaseException(message: e.toString()));
    }
  }

  Future<Result<void>> updateVariant({
    required String id,
    String? name,
    String? sku,
    String? barcode,
    double? price,
    double? cost,
  }) async {
    try {
      await (_db.update(_db.variants)..where((v) => v.id.equals(id))).write(
        VariantsCompanion(
          name: name != null ? Value(name) : const Value.absent(),
          sku: sku != null ? Value(sku) : const Value.absent(),
          barcode: barcode != null ? Value(barcode) : const Value.absent(),
          price: price != null ? Value(price) : const Value.absent(),
          cost: cost != null ? Value(cost) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to update variant', e, st);
      return Failure(DatabaseException(message: e.toString()));
    }
  }

  Future<Result<void>> deleteVariant(String id) async {
    try {
      await (_db.delete(_db.variants)..where((v) => v.id.equals(id))).go();
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to delete variant', e, st);
      return Failure(DatabaseException(message: e.toString()));
    }
  }
}
