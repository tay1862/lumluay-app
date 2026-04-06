import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumluay_pos/core/database/app_database.dart';
import 'package:lumluay_pos/features/sales/data/cart_state.dart';
import 'package:lumluay_pos/features/sales/data/sales_repository.dart';
import 'package:lumluay_pos/core/error/result.dart';

/// Integration test: full sale flow against an in-memory Drift database.
void main() {
  late AppDatabase db;
  late SalesRepository salesRepo;

  final now = DateTime.now();

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    salesRepo = SalesRepository(db);

    // Seed a store
    await db.into(db.stores).insert(StoresCompanion.insert(
      id: 'store1',
      name: 'Test Store',
    ));

    // Seed an employee
    await db.into(db.employees).insert(EmployeesCompanion.insert(
      id: 'emp1',
      storeId: 'store1',
      name: 'Test Employee',
    ));

    // Seed categories
    await db.into(db.categories).insert(CategoriesCompanion.insert(
      id: 'cat1',
      storeId: 'store1',
      name: 'Beverages',
    ));

    // Seed items
    await db.into(db.items).insert(ItemsCompanion.insert(
      id: 'item1',
      storeId: 'store1',
      name: 'Coffee',
      price: const Value(15000),
      cost: const Value(5000),
      categoryId: const Value('cat1'),
      trackStock: const Value(true),
    ));

    await db.into(db.items).insert(ItemsCompanion.insert(
      id: 'item2',
      storeId: 'store1',
      name: 'Tea',
      price: const Value(10000),
      cost: const Value(3000),
      categoryId: const Value('cat1'),
    ));

    // Seed inventory for item1 (stock tracked)
    await db.into(db.inventoryLevels).insert(InventoryLevelsCompanion.insert(
      id: 'inv1',
      itemId: 'item1',
      storeId: 'store1',
      quantity: const Value(100.0),
      lowStockThreshold: const Value(10.0),
    ));
  });

  tearDown(() async {
    await db.close();
  });

  Item getItem(String id, String name, double price, double cost) {
    return Item(
      id: id,
      storeId: 'store1',
      name: name,
      price: price,
      cost: cost,
      trackStock: id == 'item1',
      soldByWeight: false,
      active: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('Full sale flow', () {
    test('create receipt with items decrements inventory', () async {
      final cart = CartState(
        items: [
          CartItem(
            item: getItem('item1', 'Coffee', 15000, 5000),
            unitPrice: 15000,
            quantity: 3,
          ),
          CartItem(
            item: getItem('item2', 'Tea', 10000, 3000),
            unitPrice: 10000,
            quantity: 1,
          ),
        ],
        taxRate: 0.10,
        orderDiscount: 2000,
      );

      // subtotal: 15000*3 + 10000 = 55000
      expect(cart.subtotal, 55000);
      // tax: 55000 * 0.10 = 5500
      expect(cart.taxAmount, closeTo(5500, 0.01));
      // total: 55000 + 5500 - 2000 = 58500
      expect(cart.total, closeTo(58500, 0.01));

      final result = await salesRepo.createReceipt(
        storeId: 'store1',
        employeeId: 'emp1',
        cart: cart,
        paymentMethod: 'cash',
        amountPaid: 60000,
      );

      expect(result, isA<Success<String>>());

      // Verify receipt was created
      final receipts = await salesRepo.getReceipts('store1');
      expect(receipts.length, 1);
      expect(receipts.first.total, closeTo(58500, 0.01));
      expect(receipts.first.status, 'completed');

      // Verify receipt items
      final receiptItems = await (db.select(db.receiptItems)
            ..where((t) => t.receiptId.equals(receipts.first.id)))
          .get();
      expect(receiptItems.length, 2);

      // Verify payment
      final payments = await (db.select(db.payments)
            ..where((t) => t.receiptId.equals(receipts.first.id)))
          .get();
      expect(payments.length, 1);
      expect(payments.first.method, 'cash');
      expect(payments.first.amount, 60000);

      // Verify inventory was decremented (item1 had 100, sold 3 → 97)
      final inv = await (db.select(db.inventoryLevels)
            ..where((t) => t.id.equals('inv1')))
          .getSingle();
      expect(inv.quantity, 97);
    });

    test('multiple receipts generate sequential receipt numbers', () async {
      for (int i = 0; i < 3; i++) {
        final cart = CartState(items: [
          CartItem(
            item: getItem('item2', 'Tea', 10000, 3000),
            unitPrice: 10000,
          ),
        ]);

        await salesRepo.createReceipt(
          storeId: 'store1',
          employeeId: 'emp1',
          cart: cart,
          paymentMethod: 'cash',
          amountPaid: 10000,
        );
      }

      final receipts = await salesRepo.getReceipts('store1');
      expect(receipts.length, 3);

      // receipt numbers should end in -0001, -0002, -0003
      final numbers = receipts.map((r) => r.receiptNumber).toList()..sort();
      expect(numbers[0].endsWith('-0001'), true);
      expect(numbers[1].endsWith('-0002'), true);
      expect(numbers[2].endsWith('-0003'), true);
    });
  });

  group('Receipt queries', () {
    test('watchReceipts emits updates reactively', () async {
      final stream = salesRepo.watchReceipts('store1');

      // Initially empty
      final first = await stream.first;
      expect(first, isEmpty);

      // Create a receipt
      final cart = CartState(items: [
        CartItem(
          item: getItem('item2', 'Tea', 10000, 3000),
          unitPrice: 10000,
        ),
      ]);
      await salesRepo.createReceipt(
        storeId: 'store1',
        employeeId: 'emp1',
        cart: cart,
        paymentMethod: 'qr',
        amountPaid: 10000,
      );

      // Stream should emit the new receipt
      final updated = await salesRepo.watchReceipts('store1').first;
      expect(updated.length, 1);
    });
  });

  group('Refund flow', () {
    test('refund restores inventory and creates refund receipt', () async {
      // First create a sale
      final cart = CartState(items: [
        CartItem(
          item: getItem('item1', 'Coffee', 15000, 5000),
          unitPrice: 15000,
          quantity: 2,
        ),
      ]);

      final saleResult = await salesRepo.createReceipt(
        storeId: 'store1',
        employeeId: 'emp1',
        cart: cart,
        paymentMethod: 'cash',
        amountPaid: 30000,
      );

      final receiptId = (saleResult as Success<String>).value;

      // Inventory should be 98 (100 - 2)
      var inv = await (db.select(db.inventoryLevels)
            ..where((t) => t.id.equals('inv1')))
          .getSingle();
      expect(inv.quantity, 98);

      // Now refund
      final refundResult = await salesRepo.refundReceipt(
        receiptId,
        employeeId: 'emp1',
        reason: 'Customer changed mind',
      );

      expect(refundResult, isA<Success>());

      // Inventory should be restored to 100
      inv = await (db.select(db.inventoryLevels)
            ..where((t) => t.id.equals('inv1')))
          .getSingle();
      expect(inv.quantity, 100);

      // Receipt status should be refunded
      final receipt = await (db.select(db.receipts)
            ..where((t) => t.id.equals(receiptId)))
          .getSingle();
      expect(receipt.status, 'refunded');
    });
  });
}
