import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';

/// Joined model for inventory level + item name.
class InventoryStock {
  final InventoryLevel level;
  final String itemName;
  final String? sku;
  final double cost;

  const InventoryStock({
    required this.level,
    required this.itemName,
    this.sku,
    required this.cost,
  });

  double get stockValue => level.quantity * cost;

  bool get isLowStock =>
      level.lowStockThreshold > 0 && level.quantity <= level.lowStockThreshold;

  bool get isOutOfStock => level.quantity <= 0;
}

class InventoryRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  InventoryRepository(this._db);

  // ── Stock Levels ──

  /// Watch all inventory levels for a store, joined with item info.
  Stream<List<InventoryStock>> watchStockLevels(String storeId) {
    final query = _db.select(_db.inventoryLevels).join([
      innerJoin(_db.items, _db.items.id.equalsExp(_db.inventoryLevels.itemId)),
    ])
      ..where(_db.inventoryLevels.storeId.equals(storeId))
      ..orderBy([OrderingTerm.asc(_db.items.name)]);

    return query.watch().map((rows) => rows.map((row) {
          final level = row.readTable(_db.inventoryLevels);
          final item = row.readTable(_db.items);
          return InventoryStock(
            level: level,
            itemName: item.name,
            sku: item.sku,
            cost: item.cost,
          );
        }).toList());
  }

  /// Get low-stock items for a store.
  Stream<List<InventoryStock>> watchLowStock(String storeId) {
    final query = _db.select(_db.inventoryLevels).join([
      innerJoin(_db.items, _db.items.id.equalsExp(_db.inventoryLevels.itemId)),
    ])
      ..where(_db.inventoryLevels.storeId.equals(storeId) &
          _db.inventoryLevels.lowStockThreshold.isBiggerThanValue(0) &
          _db.inventoryLevels.quantity
              .isSmallerOrEqual(_db.inventoryLevels.lowStockThreshold))
      ..orderBy([OrderingTerm.asc(_db.items.name)]);

    return query.watch().map((rows) => rows.map((row) {
          final level = row.readTable(_db.inventoryLevels);
          final item = row.readTable(_db.items);
          return InventoryStock(
            level: level,
            itemName: item.name,
            sku: item.sku,
            cost: item.cost,
          );
        }).toList());
  }

  /// Ensure an inventory level record exists for an item in a store.
  Future<InventoryLevel> _ensureLevel(String storeId, String itemId) async {
    final existing = await (_db.select(_db.inventoryLevels)
          ..where(
              (t) => t.storeId.equals(storeId) & t.itemId.equals(itemId)))
        .getSingleOrNull();

    if (existing != null) return existing;

    final id = _uuid.v4();
    await _db.into(_db.inventoryLevels).insert(InventoryLevelsCompanion.insert(
          id: id,
          itemId: itemId,
          storeId: storeId,
        ));
    return (await (_db.select(_db.inventoryLevels)
              ..where((t) => t.id.equals(id)))
            .getSingle());
  }

  // ── Stock Adjustments ──

  /// Create a stock adjustment and update inventory level.
  Future<Result<void>> adjustStock({
    required String storeId,
    required String itemId,
    required double quantityChange,
    required String reason,
    String? employeeId,
    String? variantId,
  }) async {
    try {
      await _db.transaction(() async {
        // Record adjustment
        await _db.into(_db.stockAdjustments).insert(
              StockAdjustmentsCompanion.insert(
                id: _uuid.v4(),
                storeId: storeId,
                itemId: itemId,
                quantityChange: quantityChange,
                reason: reason,
                employeeId: Value(employeeId),
                variantId: Value(variantId),
              ),
            );

        // Update inventory level
        final level = await _ensureLevel(storeId, itemId);
        await (_db.update(_db.inventoryLevels)
              ..where((t) => t.id.equals(level.id)))
            .write(InventoryLevelsCompanion(
          quantity: Value(level.quantity + quantityChange),
          updatedAt: Value(DateTime.now()),
        ));
      });
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to adjust stock: $e'));
    }
  }

  /// Get adjustment history for an item.
  Future<List<StockAdjustment>> getAdjustments(
      String storeId, String itemId) async {
    return (_db.select(_db.stockAdjustments)
          ..where(
              (t) => t.storeId.equals(storeId) & t.itemId.equals(itemId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Watch all adjustments for a store.
  Stream<List<StockAdjustment>> watchAdjustments(String storeId) {
    return (_db.select(_db.stockAdjustments)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  // ── Inventory Counts ──

  /// Create a new inventory count session, populating all tracked items.
  Future<Result<String>> createInventoryCount(String storeId) async {
    try {
      final countId = _uuid.v4();
      await _db.transaction(() async {
        await _db.into(_db.inventoryCounts).insert(
              InventoryCountsCompanion.insert(id: countId, storeId: storeId),
            );

        // Get all tracked items for this store
        final items = await (_db.select(_db.items)
              ..where((t) =>
                  t.storeId.equals(storeId) &
                  t.trackStock.equals(true) &
                  t.active.equals(true)))
            .get();

        for (final item in items) {
          final level = await _ensureLevel(storeId, item.id);
          await _db.into(_db.inventoryCountItems).insert(
                InventoryCountItemsCompanion.insert(
                  id: _uuid.v4(),
                  countId: countId,
                  itemId: item.id,
                  expectedQty: Value(level.quantity),
                ),
              );
        }
      });
      return Success(countId);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to create count: $e'));
    }
  }

  /// Watch count items for a count session.
  Stream<List<InventoryCountItem>> watchCountItems(String countId) {
    return (_db.select(_db.inventoryCountItems)
          ..where((t) => t.countId.equals(countId)))
        .watch();
  }

  /// Update the counted quantity for a count item.
  Future<void> updateCountedQty(String countItemId, double countedQty) async {
    await (_db.update(_db.inventoryCountItems)
          ..where((t) => t.id.equals(countItemId)))
        .write(InventoryCountItemsCompanion(
      countedQty: Value(countedQty),
    ));
  }

  /// Complete an inventory count — apply differences as adjustments.
  Future<Result<void>> completeInventoryCount(
      String countId, String storeId, String? employeeId) async {
    try {
      await _db.transaction(() async {
        final countItems = await (_db.select(_db.inventoryCountItems)
              ..where((t) => t.countId.equals(countId)))
            .get();

        for (final ci in countItems) {
          if (ci.countedQty == null) continue;
          final diff = ci.countedQty! - ci.expectedQty;
          if (diff == 0) continue;

          // Record adjustment
          await _db.into(_db.stockAdjustments).insert(
                StockAdjustmentsCompanion.insert(
                  id: _uuid.v4(),
                  storeId: storeId,
                  itemId: ci.itemId,
                  quantityChange: diff,
                  reason: 'inventory_count',
                  employeeId: Value(employeeId),
                ),
              );

          // Update inventory level
          final level = await _ensureLevel(storeId, ci.itemId);
          await (_db.update(_db.inventoryLevels)
                ..where((t) => t.id.equals(level.id)))
              .write(InventoryLevelsCompanion(
            quantity: Value(ci.countedQty!),
            updatedAt: Value(DateTime.now()),
          ));
        }

        // Mark count as completed
        await (_db.update(_db.inventoryCounts)
              ..where((t) => t.id.equals(countId)))
            .write(InventoryCountsCompanion(
          status: const Value('completed'),
          completedAt: Value(DateTime.now()),
        ));
      });
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to complete count: $e'));
    }
  }

  /// Watch inventory counts for a store.
  Stream<List<InventoryCount>> watchInventoryCounts(String storeId) {
    return (_db.select(_db.inventoryCounts)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Update low-stock threshold for an item.
  Future<void> setLowStockThreshold(
      String storeId, String itemId, double threshold) async {
    final level = await _ensureLevel(storeId, itemId);
    await (_db.update(_db.inventoryLevels)
          ..where((t) => t.id.equals(level.id)))
        .write(InventoryLevelsCompanion(
      lowStockThreshold: Value(threshold),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Get total inventory valuation for a store.
  Future<double> getInventoryValuation(String storeId) async {
    final stock = await (_db.select(_db.inventoryLevels).join([
      innerJoin(
          _db.items, _db.items.id.equalsExp(_db.inventoryLevels.itemId)),
    ])
          ..where(_db.inventoryLevels.storeId.equals(storeId)))
        .get();

    var total = 0.0;
    for (final row in stock) {
      final level = row.readTable(_db.inventoryLevels);
      final item = row.readTable(_db.items);
      total += level.quantity * item.cost;
    }
    return total;
  }
}
