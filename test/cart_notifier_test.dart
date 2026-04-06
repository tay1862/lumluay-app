import 'package:flutter_test/flutter_test.dart';
import 'package:lumluay_pos/features/sales/data/cart_notifier.dart';
import 'package:lumluay_pos/features/sales/data/cart_state.dart';
import 'package:lumluay_pos/core/database/app_database.dart';

Item _makeItem({
  String id = 'item1',
  String name = 'Coffee',
  double price = 15000,
  double cost = 5000,
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

Variant _makeVariant({
  String id = 'v1',
  String itemId = 'item1',
  String name = 'Large',
  double price = 20000,
}) {
  final now = DateTime(2024, 1, 1);
  return Variant(
    id: id,
    variantGroupId: 'vg1',
    itemId: itemId,
    name: name,
    price: price,
    cost: 8000,
    createdAt: now,
    updatedAt: now,
  );
}

Modifier _makeModifier({
  String id = 'm1',
  String name = 'Extra Shot',
  double priceAdjustment = 5000,
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

void main() {
  late CartNotifier notifier;

  setUp(() {
    notifier = CartNotifier();
  });

  group('CartNotifier — addItem', () {
    test('adds a new item to empty cart', () {
      notifier.addItem(_makeItem());
      expect(notifier.state.items.length, 1);
      expect(notifier.state.items.first.item.name, 'Coffee');
      expect(notifier.state.items.first.quantity, 1);
      expect(notifier.state.items.first.unitPrice, 15000);
    });

    test('increments quantity when same item added again', () {
      final item = _makeItem();
      notifier.addItem(item);
      notifier.addItem(item);
      expect(notifier.state.items.length, 1);
      expect(notifier.state.items.first.quantity, 2);
    });

    test('adds new entry for same item with different variant', () {
      final item = _makeItem();
      notifier.addItem(item);
      notifier.addItem(item, variant: _makeVariant());
      expect(notifier.state.items.length, 2);
    });

    test('adds new entry for same item with different modifiers', () {
      final item = _makeItem();
      notifier.addItem(item, modifiers: [_makeModifier(id: 'm1')]);
      notifier.addItem(item, modifiers: [_makeModifier(id: 'm2', name: 'Milk')]);
      expect(notifier.state.items.length, 2);
    });

    test('uses variant price when variant provided', () {
      notifier.addItem(_makeItem(), variant: _makeVariant(price: 25000));
      expect(notifier.state.items.first.unitPrice, 25000);
    });

    test('uses overridePrice when provided', () {
      notifier.addItem(_makeItem(), overridePrice: 12000);
      expect(notifier.state.items.first.unitPrice, 12000);
    });

    test('adds item with custom quantity', () {
      notifier.addItem(_makeItem(), quantity: 5);
      expect(notifier.state.items.first.quantity, 5);
    });
  });

  group('CartNotifier — removeItem', () {
    test('removes item by cartKey', () {
      notifier.addItem(_makeItem(id: 'a'));
      notifier.addItem(_makeItem(id: 'b', name: 'Tea'));
      expect(notifier.state.items.length, 2);

      notifier.removeItem('a__');
      expect(notifier.state.items.length, 1);
      expect(notifier.state.items.first.item.name, 'Tea');
    });

    test('does nothing for non-existent key', () {
      notifier.addItem(_makeItem());
      notifier.removeItem('nonexistent');
      expect(notifier.state.items.length, 1);
    });
  });

  group('CartNotifier — updateQuantity', () {
    test('updates quantity of existing item', () {
      notifier.addItem(_makeItem());
      notifier.updateQuantity('item1__', 10);
      expect(notifier.state.items.first.quantity, 10);
    });

    test('removes item when quantity set to 0', () {
      notifier.addItem(_makeItem());
      notifier.updateQuantity('item1__', 0);
      expect(notifier.state.isEmpty, true);
    });

    test('removes item when quantity set to negative', () {
      notifier.addItem(_makeItem());
      notifier.updateQuantity('item1__', -1);
      expect(notifier.state.isEmpty, true);
    });
  });

  group('CartNotifier — increment/decrement', () {
    test('incrementQuantity increases by 1', () {
      notifier.addItem(_makeItem());
      notifier.incrementQuantity('item1__');
      expect(notifier.state.items.first.quantity, 2);
    });

    test('decrementQuantity decreases by 1', () {
      notifier.addItem(_makeItem(), quantity: 3);
      notifier.decrementQuantity('item1__');
      expect(notifier.state.items.first.quantity, 2);
    });

    test('decrementQuantity removes item at quantity 1', () {
      notifier.addItem(_makeItem());
      notifier.decrementQuantity('item1__');
      expect(notifier.state.isEmpty, true);
    });
  });

  group('CartNotifier — discounts', () {
    test('setItemDiscount applies to specific item', () {
      notifier.addItem(_makeItem());
      notifier.setItemDiscount('item1__', 2000);
      expect(notifier.state.items.first.discount, 2000);
      // lineTotal = (15000 + 0 - 2000) * 1 = 13000
      expect(notifier.state.items.first.lineTotal, 13000);
    });

    test('setOrderDiscount sets whole-order discount', () {
      notifier.setOrderDiscount(5000);
      expect(notifier.state.orderDiscount, 5000);
    });
  });

  group('CartNotifier — order settings', () {
    test('setOrderType changes order type', () {
      notifier.setOrderType(OrderType.takeaway);
      expect(notifier.state.orderType, OrderType.takeaway);
    });

    test('setCustomer assigns customer', () {
      notifier.setCustomer('cust123');
      expect(notifier.state.customerId, 'cust123');
    });

    test('setTaxRate updates tax rate', () {
      notifier.setTaxRate(0.10);
      expect(notifier.state.taxRate, 0.10);
    });

    test('setComputedTax sets computed tax total', () {
      notifier.setComputedTax(1500);
      expect(notifier.state.computedTaxTotal, 1500);
    });

    test('setCurrency updates currency and exchange rate', () {
      notifier.setCurrency('THB', exchangeRate: 0.002);
      expect(notifier.state.currencyCode, 'THB');
      expect(notifier.state.exchangeRate, 0.002);
    });
  });

  group('CartNotifier — clear', () {
    test('clear resets to empty state', () {
      notifier.addItem(_makeItem());
      notifier.setOrderDiscount(1000);
      notifier.setTaxRate(0.10);
      notifier.setCustomer('cust1');
      notifier.setCurrency('THB', exchangeRate: 0.002);

      notifier.clear();

      expect(notifier.state.isEmpty, true);
      expect(notifier.state.orderDiscount, 0);
      expect(notifier.state.taxRate, 0);
      expect(notifier.state.customerId, isNull);
      expect(notifier.state.currencyCode, 'LAK');
      expect(notifier.state.exchangeRate, 1.0);
    });
  });

  group('CartNotifier — full sale flow', () {
    test('simulates complete sale: add items, discount, tax, total', () {
      // Add 2x Coffee at 15,000
      notifier.addItem(_makeItem(), quantity: 2);
      // Add 1x Tea at 10,000
      notifier.addItem(_makeItem(id: 'tea', name: 'Tea', price: 10000));
      // Add Large Coffee variant at 20,000 with Extra Shot modifier +5,000
      notifier.addItem(
        _makeItem(),
        variant: _makeVariant(price: 20000),
        modifiers: [_makeModifier(priceAdjustment: 5000)],
      );

      // Set 10% tax
      notifier.setTaxRate(0.10);
      // Set order discount 5,000
      notifier.setOrderDiscount(5000);

      // Verify cart state
      expect(notifier.state.itemCount, 4); // 2 + 1 + 1
      expect(notifier.state.items.length, 3); // 3 line items

      // Subtotal: (15000*2) + (10000*1) + ((20000+5000)*1) = 30000 + 10000 + 25000 = 65000
      expect(notifier.state.subtotal, 65000);

      // Tax: 65000 * 0.10 = 6500
      expect(notifier.state.taxAmount, closeTo(6500, 0.01));

      // Total: 65000 + 6500 - 5000 = 66500
      expect(notifier.state.total, closeTo(66500, 0.01));
    });
  });
}
