import 'package:flutter_test/flutter_test.dart';
import 'package:lumluay_pos/core/database/app_database.dart';
import 'package:lumluay_pos/features/sales/data/cart_state.dart';

/// Helper to create a minimal Item for testing
Item _makeItem({
  String id = 'i1',
  String name = 'Test Item',
  double price = 100,
  double cost = 50,
}) {
  final now = DateTime(2024, 1, 1);
  return Item(
    id: id,
    storeId: 's1',
    name: name,
    price: price,
    cost: cost,
    trackStock: false,
    soldByWeight: false,
    active: true,
    createdAt: now,
    updatedAt: now,
  );
}

Modifier _makeModifier({
  String id = 'm1',
  String name = 'Extra Cheese',
  double priceAdjustment = 20,
}) {
  final now = DateTime(2024, 1, 1);
  return Modifier(
    id: id,
    modifierGroupId: 'mg1',
    name: name,
    priceAdjustment: priceAdjustment,
    createdAt: now,
    updatedAt: now,
  );
}

Variant _makeVariant({
  String id = 'v1',
  String name = 'Large',
  double price = 150,
}) {
  final now = DateTime(2024, 1, 1);
  return Variant(
    id: id,
    variantGroupId: 'vg1',
    itemId: 'i1',
    name: name,
    price: price,
    cost: 70,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CartItem', () {
    test('cartKey without variant or modifiers', () {
      final ci = CartItem(item: _makeItem(), unitPrice: 100);
      expect(ci.cartKey, 'i1__');
    });

    test('cartKey with variant', () {
      final ci = CartItem(
        item: _makeItem(),
        variant: _makeVariant(),
        unitPrice: 150,
      );
      expect(ci.cartKey, 'i1_v1_');
    });

    test('cartKey with modifiers sorts by id', () {
      final ci = CartItem(
        item: _makeItem(),
        modifiers: [
          _makeModifier(id: 'm2', name: 'B'),
          _makeModifier(id: 'm1', name: 'A'),
        ],
        unitPrice: 100,
      );
      expect(ci.cartKey, 'i1__m1,m2');
    });

    test('modifierTotal sums all modifier prices', () {
      final ci = CartItem(
        item: _makeItem(),
        modifiers: [
          _makeModifier(priceAdjustment: 10),
          _makeModifier(id: 'm2', priceAdjustment: 25),
        ],
        unitPrice: 100,
      );
      expect(ci.modifierTotal, 35);
    });

    test('lineTotal with no modifiers or discount', () {
      final ci = CartItem(item: _makeItem(), unitPrice: 100, quantity: 3);
      expect(ci.lineTotal, 300);
    });

    test('lineTotal with modifiers and discount', () {
      final ci = CartItem(
        item: _makeItem(),
        modifiers: [_makeModifier(priceAdjustment: 20)],
        unitPrice: 100,
        discount: 10,
        quantity: 2,
      );
      // (100 + 20 - 10) * 2 = 220
      expect(ci.lineTotal, 220);
    });

    test('copyWith creates new instance with overridden fields', () {
      final ci = CartItem(item: _makeItem(), unitPrice: 100, quantity: 1);
      final updated = ci.copyWith(quantity: 5, discount: 10);
      expect(updated.quantity, 5);
      expect(updated.discount, 10);
      expect(updated.unitPrice, 100); // unchanged
    });
  });

  group('CartState', () {
    test('empty cart defaults', () {
      const state = CartState();
      expect(state.isEmpty, true);
      expect(state.itemCount, 0);
      expect(state.subtotal, 0);
      expect(state.taxAmount, 0);
      expect(state.total, 0);
      expect(state.displayTotal, 0);
      expect(state.currencyCode, 'LAK');
      expect(state.orderType, OrderType.dineIn);
    });

    test('subtotal sums line totals', () {
      final state = CartState(items: [
        CartItem(item: _makeItem(price: 100), unitPrice: 100, quantity: 2),
        CartItem(item: _makeItem(id: 'i2', price: 50), unitPrice: 50),
      ]);
      expect(state.subtotal, 250);
    });

    test('taxAmount uses flat rate when no computedTaxTotal', () {
      final state = CartState(
        items: [CartItem(item: _makeItem(), unitPrice: 100)],
        taxRate: 0.10,
      );
      expect(state.taxAmount, closeTo(10.0, 0.001));
    });

    test('taxAmount prefers computedTaxTotal over flat rate', () {
      final state = CartState(
        items: [CartItem(item: _makeItem(), unitPrice: 100)],
        taxRate: 0.10,
        computedTaxTotal: 15.0,
      );
      expect(state.taxAmount, 15.0);
    });

    test('total = subtotal + tax - discount', () {
      final state = CartState(
        items: [CartItem(item: _makeItem(price: 200), unitPrice: 200)],
        taxRate: 0.10,
        orderDiscount: 20,
      );
      // subtotal=200, tax=20, discount=20, total=200
      expect(state.total, 200);
    });

    test('displayTotal applies exchange rate', () {
      final state = CartState(
        items: [CartItem(item: _makeItem(price: 20000), unitPrice: 20000)],
        exchangeRate: 0.002,
      );
      // 20000 * 0.002 = 40
      expect(state.displayTotal, closeTo(40, 0.01));
    });

    test('itemCount sums quantities', () {
      final state = CartState(items: [
        CartItem(item: _makeItem(), unitPrice: 100, quantity: 3),
        CartItem(
          item: _makeItem(id: 'i2'),
          unitPrice: 50,
          quantity: 2,
        ),
      ]);
      expect(state.itemCount, 5);
    });

    test('copyWith preserves unmodified fields', () {
      const state = CartState(taxRate: 0.07, currencyCode: 'THB');
      final updated = state.copyWith(orderDiscount: 50);
      expect(updated.taxRate, 0.07);
      expect(updated.currencyCode, 'THB');
      expect(updated.orderDiscount, 50);
    });
  });
}
