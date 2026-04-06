import '../../../core/database/app_database.dart';

class CartItem {
  final Item item;
  final Variant? variant;
  final List<Modifier> modifiers;
  final int quantity;
  final double unitPrice;
  final double discount;
  final String? note;

  const CartItem({
    required this.item,
    this.variant,
    this.modifiers = const [],
    this.quantity = 1,
    required this.unitPrice,
    this.discount = 0,
    this.note,
  });

  /// Unique key combining item + variant + modifiers for deduplication
  String get cartKey {
    final modIds = modifiers.map((m) => m.id).toList()..sort();
    return '${item.id}_${variant?.id ?? ''}_${modIds.join(',')}';
  }

  double get modifierTotal =>
      modifiers.fold(0.0, (sum, m) => sum + m.priceAdjustment);

  double get lineTotal => (unitPrice + modifierTotal - discount) * quantity;

  CartItem copyWith({
    Item? item,
    Variant? variant,
    List<Modifier>? modifiers,
    int? quantity,
    double? unitPrice,
    double? discount,
    String? note,
  }) {
    return CartItem(
      item: item ?? this.item,
      variant: variant ?? this.variant,
      modifiers: modifiers ?? this.modifiers,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
      note: note ?? this.note,
    );
  }
}

enum OrderType { dineIn, takeaway, delivery }

class CartState {
  final List<CartItem> items;
  final String? customerId;
  final OrderType orderType;
  final double taxRate;
  final double orderDiscount;
  final String currencyCode;
  /// Per-item tax total (computed by TaxService)
  final double computedTaxTotal;
  /// Exchange rate for multi-currency (1.0 = primary currency)
  final double exchangeRate;

  const CartState({
    this.items = const [],
    this.customerId,
    this.orderType = OrderType.dineIn,
    this.taxRate = 0.0,
    this.orderDiscount = 0.0,
    this.currencyCode = 'LAK',
    this.computedTaxTotal = 0.0,
    this.exchangeRate = 1.0,
  });

  double get subtotal => items.fold(0, (sum, i) => sum + i.lineTotal);
  /// Use computedTaxTotal if set (from TaxService), else fallback to flat rate
  double get taxAmount =>
      computedTaxTotal > 0 ? computedTaxTotal : subtotal * taxRate;
  double get total => subtotal + taxAmount - orderDiscount;
  /// Total in display currency (applying exchange rate)
  double get displayTotal => total * exchangeRate;
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItem>? items,
    String? customerId,
    OrderType? orderType,
    double? taxRate,
    double? orderDiscount,
    String? currencyCode,
    double? computedTaxTotal,
    double? exchangeRate,
  }) {
    return CartState(
      items: items ?? this.items,
      customerId: customerId ?? this.customerId,
      orderType: orderType ?? this.orderType,
      taxRate: taxRate ?? this.taxRate,
      orderDiscount: orderDiscount ?? this.orderDiscount,
      currencyCode: currencyCode ?? this.currencyCode,
      computedTaxTotal: computedTaxTotal ?? this.computedTaxTotal,
      exchangeRate: exchangeRate ?? this.exchangeRate,
    );
  }
}
