import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';

/// Joined model for purchase order + supplier name.
class PurchaseOrderWithSupplier {
  final PurchaseOrder po;
  final String? supplierName;
  final int itemCount;

  const PurchaseOrderWithSupplier({
    required this.po,
    this.supplierName,
    this.itemCount = 0,
  });
}

/// Joined model for PO item + item name.
class POItemWithName {
  final PurchaseOrderItem poItem;
  final String itemName;
  final String? sku;

  const POItemWithName({
    required this.poItem,
    required this.itemName,
    this.sku,
  });
}

class PurchaseOrderRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  PurchaseOrderRepository(this._db);

  // ── Suppliers ──

  Stream<List<Supplier>> watchSuppliers(String storeId) {
    return (_db.select(_db.suppliers)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<Result<String>> createSupplier({
    required String storeId,
    required String name,
    String? phone,
    String? email,
    String? address,
  }) async {
    try {
      final id = _uuid.v4();
      await _db.into(_db.suppliers).insert(SuppliersCompanion.insert(
            id: id,
            storeId: storeId,
            name: name,
            phone: Value(phone),
            email: Value(email),
            address: Value(address),
          ));
      return Success(id);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to create supplier: $e'));
    }
  }

  Future<Result<void>> updateSupplier({
    required String id,
    required String name,
    String? phone,
    String? email,
    String? address,
  }) async {
    try {
      await (_db.update(_db.suppliers)..where((t) => t.id.equals(id)))
          .write(SuppliersCompanion(
        name: Value(name),
        phone: Value(phone),
        email: Value(email),
        address: Value(address),
        updatedAt: Value(DateTime.now()),
      ));
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to update supplier: $e'));
    }
  }

  Future<Result<void>> deleteSupplier(String id) async {
    try {
      await (_db.delete(_db.suppliers)..where((t) => t.id.equals(id))).go();
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to delete supplier: $e'));
    }
  }

  // ── Purchase Orders ──

  Stream<List<PurchaseOrderWithSupplier>> watchPurchaseOrders(
      String storeId) {
    final query = _db.select(_db.purchaseOrders).join([
      leftOuterJoin(
        _db.suppliers,
        _db.suppliers.id.equalsExp(_db.purchaseOrders.supplierId),
      ),
    ])
      ..where(_db.purchaseOrders.storeId.equals(storeId))
      ..orderBy([OrderingTerm.desc(_db.purchaseOrders.createdAt)]);

    return query.watch().asyncMap((rows) async {
      final results = <PurchaseOrderWithSupplier>[];
      for (final row in rows) {
        final po = row.readTable(_db.purchaseOrders);
        final supplier = row.readTableOrNull(_db.suppliers);
        final count = await (_db.select(_db.purchaseOrderItems)
              ..where((t) => t.poId.equals(po.id)))
            .get();
        results.add(PurchaseOrderWithSupplier(
          po: po,
          supplierName: supplier?.name,
          itemCount: count.length,
        ));
      }
      return results;
    });
  }

  Future<Result<String>> createPurchaseOrder({
    required String storeId,
    String? supplierId,
    String currency = 'LAK',
    required List<({String itemId, double quantity, double cost})> items,
  }) async {
    try {
      final poId = _uuid.v4();
      await _db.transaction(() async {
        var total = 0.0;
        for (final item in items) {
          total += item.quantity * item.cost;
        }

        await _db.into(_db.purchaseOrders).insert(
              PurchaseOrdersCompanion.insert(
                id: poId,
                storeId: storeId,
                supplierId: Value(supplierId),
                currency: Value(currency),
                total: Value(total),
              ),
            );

        for (final item in items) {
          await _db.into(_db.purchaseOrderItems).insert(
                PurchaseOrderItemsCompanion.insert(
                  id: _uuid.v4(),
                  poId: poId,
                  itemId: item.itemId,
                  quantity: item.quantity,
                  cost: Value(item.cost),
                ),
              );
        }
      });
      return Success(poId);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to create PO: $e'));
    }
  }

  /// Mark PO as ordered.
  Future<Result<void>> markOrdered(String poId) async {
    try {
      await (_db.update(_db.purchaseOrders)
            ..where((t) => t.id.equals(poId)))
          .write(PurchaseOrdersCompanion(
        status: const Value('ordered'),
        updatedAt: Value(DateTime.now()),
      ));
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseException(message: 'Failed to update PO: $e'));
    }
  }

  /// Watch PO items with item names.
  Stream<List<POItemWithName>> watchPOItems(String poId) {
    final query = _db.select(_db.purchaseOrderItems).join([
      innerJoin(
          _db.items, _db.items.id.equalsExp(_db.purchaseOrderItems.itemId)),
    ])
      ..where(_db.purchaseOrderItems.poId.equals(poId));

    return query.watch().map((rows) => rows.map((row) {
          final poItem = row.readTable(_db.purchaseOrderItems);
          final item = row.readTable(_db.items);
          return POItemWithName(
            poItem: poItem,
            itemName: item.name,
            sku: item.sku,
          );
        }).toList());
  }

  /// Receive stock from a PO — updates inventory and marks PO received.
  Future<Result<void>> receiveStock({
    required String poId,
    required String storeId,
    required List<({String itemId, double receivedQty})> receivedItems,
    String? employeeId,
  }) async {
    try {
      await _db.transaction(() async {
        for (final recv in receivedItems) {
          if (recv.receivedQty <= 0) continue;

          // Record stock adjustment
          await _db.into(_db.stockAdjustments).insert(
                StockAdjustmentsCompanion.insert(
                  id: _uuid.v4(),
                  storeId: storeId,
                  itemId: recv.itemId,
                  quantityChange: recv.receivedQty,
                  reason: 'purchase_order',
                  employeeId: Value(employeeId),
                ),
              );

          // Update inventory level
          final existing = await (_db.select(_db.inventoryLevels)
                ..where((t) =>
                    t.storeId.equals(storeId) &
                    t.itemId.equals(recv.itemId)))
              .getSingleOrNull();

          if (existing != null) {
            await (_db.update(_db.inventoryLevels)
                  ..where((t) => t.id.equals(existing.id)))
                .write(InventoryLevelsCompanion(
              quantity: Value(existing.quantity + recv.receivedQty),
              updatedAt: Value(DateTime.now()),
            ));
          } else {
            await _db.into(_db.inventoryLevels).insert(
                  InventoryLevelsCompanion.insert(
                    id: _uuid.v4(),
                    itemId: recv.itemId,
                    storeId: storeId,
                    quantity: Value(recv.receivedQty),
                  ),
                );
          }
        }

        // Mark PO as received
        await (_db.update(_db.purchaseOrders)
              ..where((t) => t.id.equals(poId)))
            .write(PurchaseOrdersCompanion(
          status: const Value('received'),
          updatedAt: Value(DateTime.now()),
        ));
      });
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to receive stock: $e'));
    }
  }

  /// Delete a draft PO and its items.
  Future<Result<void>> deletePurchaseOrder(String poId) async {
    try {
      await _db.transaction(() async {
        await (_db.delete(_db.purchaseOrderItems)
              ..where((t) => t.poId.equals(poId)))
            .go();
        await (_db.delete(_db.purchaseOrders)
              ..where((t) => t.id.equals(poId)))
            .go();
      });
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to delete PO: $e'));
    }
  }
}
