import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import 'cart_state.dart';

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addItem(
    Item item, {
    int quantity = 1,
    double? overridePrice,
    Variant? variant,
    List<Modifier> modifiers = const [],
  }) {
    final probe = CartItem(
      item: item,
      variant: variant,
      modifiers: modifiers,
      unitPrice: overridePrice ?? variant?.price ?? item.price,
    );
    final existing = state.items.indexWhere((ci) => ci.cartKey == probe.cartKey);

    if (existing >= 0) {
      final updated = List<CartItem>.from(state.items);
      final old = updated[existing];
      updated[existing] = old.copyWith(quantity: old.quantity + quantity);
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(
            item: item,
            variant: variant,
            modifiers: modifiers,
            quantity: quantity,
            unitPrice: overridePrice ?? variant?.price ?? item.price,
          ),
        ],
      );
    }
  }

  void removeItem(String cartKey) {
    state = state.copyWith(
      items: state.items.where((ci) => ci.cartKey != cartKey).toList(),
    );
  }

  void updateQuantity(String cartKey, int quantity) {
    if (quantity <= 0) {
      removeItem(cartKey);
      return;
    }
    final updated = state.items.map((ci) {
      if (ci.cartKey == cartKey) return ci.copyWith(quantity: quantity);
      return ci;
    }).toList();
    state = state.copyWith(items: updated);
  }

  void incrementQuantity(String cartKey) {
    final updated = state.items.map((ci) {
      if (ci.cartKey == cartKey) return ci.copyWith(quantity: ci.quantity + 1);
      return ci;
    }).toList();
    state = state.copyWith(items: updated);
  }

  void decrementQuantity(String cartKey) {
    final item = state.items.firstWhere((ci) => ci.cartKey == cartKey);
    if (item.quantity <= 1) {
      removeItem(cartKey);
    } else {
      updateQuantity(cartKey, item.quantity - 1);
    }
  }

  void setItemDiscount(String cartKey, double discount) {
    final updated = state.items.map((ci) {
      if (ci.cartKey == cartKey) return ci.copyWith(discount: discount);
      return ci;
    }).toList();
    state = state.copyWith(items: updated);
  }

  void setOrderDiscount(double discount) {
    state = state.copyWith(orderDiscount: discount);
  }

  void setOrderType(OrderType type) {
    state = state.copyWith(orderType: type);
  }

  void setCustomer(String? customerId) {
    state = state.copyWith(customerId: customerId);
  }

  void setTaxRate(double rate) {
    state = state.copyWith(taxRate: rate);
  }

  void setComputedTax(double taxTotal) {
    state = state.copyWith(computedTaxTotal: taxTotal);
  }

  void setCurrency(String code, {double exchangeRate = 1.0}) {
    state = state.copyWith(currencyCode: code, exchangeRate: exchangeRate);
  }

  void clear() {
    state = const CartState();
  }
}
