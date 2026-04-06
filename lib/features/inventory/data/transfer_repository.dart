import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';

/// Joined model for transfer item + item name.
class TransferItemWithName {
  final TransferOrderItem transferItem;
  final String itemName;
  final String? sku;

  const TransferItemWithName({
    required this.transferItem,
    required this.itemName,
    this.sku,
  });
}

class TransferRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  TransferRepository(this._db);

  /// Watch all transfers involving a store (as source or destination).
  Stream<List<TransferOrder>> watchTransfers(String storeId) {
    return (_db.select(_db.transferOrders)
          ..where((t) =>
              t.fromStoreId.equals(storeId) | t.toStoreId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Watch items for a transfer.
  Stream<List<TransferItemWithName>> watchTransferItems(String transferId) {
    final query = _db.select(_db.transferOrderItems).join([
      innerJoin(
          _db.items, _db.items.id.equalsExp(_db.transferOrderItems.itemId)),
    ])
      ..where(_db.transferOrderItems.transferId.equals(transferId));

    return query.watch().map((rows) => rows.map((row) {
          final ti = row.readTable(_db.transferOrderItems);
          final item = row.readTable(_db.items);
          return TransferItemWithName(
            transferItem: ti,
            itemName: item.name,
            sku: item.sku,
          );
        }).toList());
  }

  /// Create a transfer order and deduct stock from source store.
  Future<Result<String>> createTransfer({
    required String fromStoreId,
    required String toStoreId,
    required List<({String itemId, double quantity})> items,
    String? employeeId,
  }) async {
    try {
      final transferId = _uuid.v4();
      await _db.transaction(() async {
        await _db.into(_db.transferOrders).insert(
              TransferOrdersCompanion.insert(
                id: transferId,
                fromStoreId: fromStoreId,
                toStoreId: toStoreId,
                status: const Value('in_transit'),
              ),
            );

        for (final item in items) {
          await _db.into(_db.transferOrderItems).insert(
                TransferOrderItemsCompanion.insert(
                  id: _uuid.v4(),
                  transferId: transferId,
                  itemId: item.itemId,
                  quantity: item.quantity,
                ),
              );

          // Deduct from source store
          await _db.into(_db.stockAdjustments).insert(
                StockAdjustmentsCompanion.insert(
                  id: _uuid.v4(),
                  storeId: fromStoreId,
                  itemId: item.itemId,
                  quantityChange: -item.quantity,
                  reason: 'transfer_out',
                  employeeId: Value(employeeId),
                ),
              );

          final srcLevel = await (_db.select(_db.inventoryLevels)
                ..where((t) =>
                    t.storeId.equals(fromStoreId) &
                    t.itemId.equals(item.itemId)))
              .getSingleOrNull();
          if (srcLevel != null) {
            await (_db.update(_db.inventoryLevels)
                  ..where((t) => t.id.equals(srcLevel.id)))
                .write(InventoryLevelsCompanion(
              quantity: Value(srcLevel.quantity - item.quantity),
              updatedAt: Value(DateTime.now()),
            ));
          }
        }
      });
      return Success(transferId);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to create transfer: $e'));
    }
  }

  /// Complete a transfer — add stock to destination store.
  Future<Result<void>> completeTransfer({
    required String transferId,
    String? employeeId,
  }) async {
    try {
      await _db.transaction(() async {
        final transfer = await (_db.select(_db.transferOrders)
              ..where((t) => t.id.equals(transferId)))
            .getSingle();

        final items = await (_db.select(_db.transferOrderItems)
              ..where((t) => t.transferId.equals(transferId)))
            .get();

        for (final ti in items) {
          // Add to destination store
          await _db.into(_db.stockAdjustments).insert(
                StockAdjustmentsCompanion.insert(
                  id: _uuid.v4(),
                  storeId: transfer.toStoreId,
                  itemId: ti.itemId,
                  quantityChange: ti.quantity,
                  reason: 'transfer_in',
                  employeeId: Value(employeeId),
                ),
              );

          final destLevel = await (_db.select(_db.inventoryLevels)
                ..where((t) =>
                    t.storeId.equals(transfer.toStoreId) &
                    t.itemId.equals(ti.itemId)))
              .getSingleOrNull();

          if (destLevel != null) {
            await (_db.update(_db.inventoryLevels)
                  ..where((t) => t.id.equals(destLevel.id)))
                .write(InventoryLevelsCompanion(
              quantity: Value(destLevel.quantity + ti.quantity),
              updatedAt: Value(DateTime.now()),
            ));
          } else {
            await _db.into(_db.inventoryLevels).insert(
                  InventoryLevelsCompanion.insert(
                    id: _uuid.v4(),
                    itemId: ti.itemId,
                    storeId: transfer.toStoreId,
                    quantity: Value(ti.quantity),
                  ),
                );
          }
        }

        // Mark completed
        await (_db.update(_db.transferOrders)
              ..where((t) => t.id.equals(transferId)))
            .write(TransferOrdersCompanion(
          status: const Value('completed'),
          updatedAt: Value(DateTime.now()),
        ));
      });
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to complete transfer: $e'));
    }
  }
}
