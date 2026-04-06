import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import 'cart_state.dart';

class SalesRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  SalesRepository(this._db);

  /// Generate sequential receipt number: STORE-YYYYMMDD-NNN
  Future<String> _nextReceiptNumber(String storeId) async {
    final now = DateTime.now();
    final datePrefix =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    // Count today's receipts for this store
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final count = await (_db.select(_db.receipts)
          ..where((t) =>
              t.storeId.equals(storeId) &
              t.createdAt.isBiggerOrEqualValue(startOfDay) &
              t.createdAt.isSmallerThanValue(endOfDay)))
        .get();

    final seq = (count.length + 1).toString().padLeft(4, '0');
    return '$datePrefix-$seq';
  }

  /// Decrement inventory for sold items
  Future<void> _decrementInventory(
      String storeId, List<CartItem> items) async {
    for (final ci in items) {
      // Only decrement if item tracks stock
      final item = await (_db.select(_db.items)
            ..where((t) => t.id.equals(ci.item.id)))
          .getSingleOrNull();
      if (item == null || !item.trackStock) continue;

      final inv = await (_db.select(_db.inventoryLevels)
            ..where((t) =>
                t.itemId.equals(ci.item.id) & t.storeId.equals(storeId)))
          .getSingleOrNull();

      if (inv != null) {
        await (_db.update(_db.inventoryLevels)
              ..where((t) => t.id.equals(inv.id)))
            .write(InventoryLevelsCompanion(
          quantity: Value(inv.quantity - ci.quantity),
          updatedAt: Value(DateTime.now()),
        ));
      }
    }
  }

  /// Restore inventory for refunded items
  Future<void> _restoreInventory(
      String storeId, List<ReceiptItem> items) async {
    for (final ri in items) {
      if (ri.itemId == null) continue;

      final item = await (_db.select(_db.items)
            ..where((t) => t.id.equals(ri.itemId!)))
          .getSingleOrNull();
      if (item == null || !item.trackStock) continue;

      final inv = await (_db.select(_db.inventoryLevels)
            ..where((t) =>
                t.itemId.equals(ri.itemId!) & t.storeId.equals(storeId)))
          .getSingleOrNull();

      if (inv != null) {
        await (_db.update(_db.inventoryLevels)
              ..where((t) => t.id.equals(inv.id)))
            .write(InventoryLevelsCompanion(
          quantity: Value(inv.quantity + ri.quantity),
          updatedAt: Value(DateTime.now()),
        ));
      }
    }
  }

  Future<Result<String>> createReceipt({
    required String storeId,
    required String employeeId,
    required CartState cart,
    required String paymentMethod,
    required double amountPaid,
  }) async {
    try {
      final receiptId = _uuid.v4();
      final receiptNumber = await _nextReceiptNumber(storeId);

      await _db.transaction(() async {
        // Insert receipt
        await _db.into(_db.receipts).insert(
              ReceiptsCompanion.insert(
                id: receiptId,
                storeId: storeId,
                receiptNumber: receiptNumber,
                employeeId: Value(employeeId),
                customerId: Value(cart.customerId),
                diningOption: Value(cart.orderType.name),
                subtotal: Value(cart.subtotal),
                taxTotal: Value(cart.taxAmount),
                discountTotal: Value(cart.orderDiscount),
                total: Value(cart.total),
                status: const Value('completed'),
                currency: Value(cart.currencyCode),
              ),
            );

        // Insert receipt items
        for (final ci in cart.items) {
          await _db.into(_db.receiptItems).insert(
                ReceiptItemsCompanion.insert(
                  id: _uuid.v4(),
                  receiptId: receiptId,
                  itemId: Value(ci.item.id),
                  name: ci.item.name,
                  quantity: Value(ci.quantity.toDouble()),
                  unitPrice: Value(ci.unitPrice),
                  discount: Value(ci.discount),
                  total: Value(ci.lineTotal),
                ),
              );
        }

        // Insert payment
        await _db.into(_db.payments).insert(
              PaymentsCompanion.insert(
                id: _uuid.v4(),
                receiptId: receiptId,
                method: paymentMethod,
                amount: amountPaid,
                currency: Value(cart.currencyCode),
              ),
            );

        // Decrement inventory
        await _decrementInventory(storeId, cart.items);
      });

      return Success(receiptId);
    } catch (e, st) {
      AppLogger.error('Failed to create receipt', e, st);
      return Failure(
          DatabaseException(message: 'Failed to create receipt', originalError: e));
    }
  }

  /// Watch receipts stream for reactive UI
  Stream<List<Receipt>> watchReceipts(
    String storeId, {
    DateTime? from,
    DateTime? to,
    int limit = 50,
  }) {
    final query = _db.select(_db.receipts)
      ..where((t) => t.storeId.equals(storeId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit);

    if (from != null) {
      query.where((t) => t.createdAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.createdAt.isSmallerOrEqualValue(to));
    }

    return query.watch();
  }

  Future<List<Receipt>> getReceipts(
    String storeId, {
    DateTime? from,
    DateTime? to,
    int limit = 50,
    int offset = 0,
  }) async {
    final query = _db.select(_db.receipts)
      ..where((t) => t.storeId.equals(storeId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit, offset: offset);

    if (from != null) {
      query.where((t) => t.createdAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.createdAt.isSmallerOrEqualValue(to));
    }

    return query.get();
  }

  Future<Receipt?> getReceiptById(String id) async {
    return (_db.select(_db.receipts)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<ReceiptItem>> getReceiptItems(String receiptId) async {
    return (_db.select(_db.receiptItems)
          ..where((t) => t.receiptId.equals(receiptId)))
        .get();
  }

  Future<List<Payment>> getPayments(String receiptId) async {
    return (_db.select(_db.payments)
          ..where((t) => t.receiptId.equals(receiptId)))
        .get();
  }

  Future<Result<void>> voidReceipt(String receiptId) async {
    try {
      await _db.transaction(() async {
        final receipt = await getReceiptById(receiptId);
        if (receipt == null) return;

        await (_db.update(_db.receipts)
              ..where((t) => t.id.equals(receiptId)))
            .write(const ReceiptsCompanion(status: Value('voided')));

        // Restore inventory
        final items = await getReceiptItems(receiptId);
        await _restoreInventory(receipt.storeId, items);
      });
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to void receipt', e, st);
      return Failure(
          DatabaseException(message: 'Failed to void receipt', originalError: e));
    }
  }

  Future<Result<String>> refundReceipt(
    String originalReceiptId, {
    required String employeeId,
    required String reason,
  }) async {
    try {
      final original = await getReceiptById(originalReceiptId);
      if (original == null) {
        return const Failure(
            DatabaseException(message: 'Original receipt not found'));
      }

      final refundId = _uuid.v4();
      final refundNumber =
          'R-${await _nextReceiptNumber(original.storeId)}';

      await _db.transaction(() async {
        // Mark original as refunded
        await (_db.update(_db.receipts)
              ..where((t) => t.id.equals(originalReceiptId)))
            .write(const ReceiptsCompanion(status: Value('refunded')));

        // Create refund receipt
        await _db.into(_db.receipts).insert(
              ReceiptsCompanion.insert(
                id: refundId,
                storeId: original.storeId,
                receiptNumber: refundNumber,
                employeeId: Value(employeeId),
                customerId: Value(original.customerId),
                subtotal: Value(-original.subtotal),
                taxTotal: Value(-original.taxTotal),
                discountTotal: Value(-original.discountTotal),
                total: Value(-original.total),
                status: const Value('refund'),
              ),
            );

        // Copy receipt items as negative
        final originalItems = await getReceiptItems(originalReceiptId);
        for (final item in originalItems) {
          await _db.into(_db.receiptItems).insert(
                ReceiptItemsCompanion.insert(
                  id: _uuid.v4(),
                  receiptId: refundId,
                  itemId: Value(item.itemId),
                  name: item.name,
                  quantity: Value(-item.quantity),
                  unitPrice: Value(item.unitPrice),
                  discount: Value(item.discount),
                  total: Value(-item.total),
                ),
              );
        }

        // Insert refund payment
        await _db.into(_db.payments).insert(
              PaymentsCompanion.insert(
                id: _uuid.v4(),
                receiptId: refundId,
                method: 'cash',
                amount: -original.total,
                currency: Value(original.currency),
                reference: Value('Refund: $reason'),
              ),
            );

        // Restore inventory
        await _restoreInventory(original.storeId, originalItems);
      });

      return Success(refundId);
    } catch (e, st) {
      AppLogger.error('Failed to refund receipt', e, st);
      return Failure(
          DatabaseException(message: 'Failed to refund receipt', originalError: e));
    }
  }
}
