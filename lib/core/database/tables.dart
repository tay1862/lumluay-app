import 'package:drift/drift.dart';

// ============================================================
// STORES
// ============================================================

class Stores extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get currency => text().withDefault(const Constant('LAK'))();
  TextColumn get timezone => text().withDefault(const Constant('Asia/Vientiane'))();
  TextColumn get logo => text().nullable()();
  TextColumn get secondaryCurrencies => text().withDefault(const Constant('[]'))();
  TextColumn get exchangeRates => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// CATEGORIES
// ============================================================

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get color => text().withDefault(const Constant('#6366F1'))();
  TextColumn get icon => text().withDefault(const Constant('category'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// ITEMS
// ============================================================

class Items extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  RealColumn get price => real().withDefault(const Constant(0.0))();
  RealColumn get cost => real().withDefault(const Constant(0.0))();
  TextColumn get taxGroupId => text().nullable()();
  BoolColumn get trackStock => boolean().withDefault(const Constant(false))();
  BoolColumn get soldByWeight => boolean().withDefault(const Constant(false))();
  TextColumn get imagePath => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// VARIANTS
// ============================================================

class VariantGroups extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Variants extends Table {
  TextColumn get id => text()();
  TextColumn get variantGroupId => text().references(VariantGroups, #id)();
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  RealColumn get price => real().withDefault(const Constant(0.0))();
  RealColumn get cost => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// MODIFIERS
// ============================================================

class ModifierGroups extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  IntColumn get minSelect => integer().withDefault(const Constant(0))();
  IntColumn get maxSelect => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Modifiers extends Table {
  TextColumn get id => text()();
  TextColumn get modifierGroupId => text().references(ModifierGroups, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  RealColumn get priceAdjustment => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ItemModifierGroups extends Table {
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get modifierGroupId => text().references(ModifierGroups, #id)();

  @override
  Set<Column> get primaryKey => {itemId, modifierGroupId};
}

// ============================================================
// CUSTOMERS & LOYALTY
// ============================================================

class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  RealColumn get loyaltyPoints => real().withDefault(const Constant(0.0))();
  RealColumn get totalSpent => real().withDefault(const Constant(0.0))();
  IntColumn get visitCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get birthday => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LoyaltySettings extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  RealColumn get pointsPerCurrency => real().withDefault(const Constant(1.0))();
  RealColumn get currencyPerPoint => real().withDefault(const Constant(1.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LoyaltyTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text().references(Customers, #id)();
  TextColumn get receiptId => text().nullable()();
  RealColumn get points => real()();
  TextColumn get type => text()(); // earn, redeem, adjust
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// EMPLOYEES & ROLES
// ============================================================

class EmployeeRoles extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get permissions => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Employees extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get pinHash => text().nullable()();
  TextColumn get pinSalt => text().nullable()();
  TextColumn get roleId => text().nullable().references(EmployeeRoles, #id)();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class TimeEntries extends Table {
  TextColumn get id => text()();
  TextColumn get employeeId => text().references(Employees, #id)();
  DateTimeColumn get clockIn => dateTime()();
  DateTimeColumn get clockOut => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// RECEIPTS & PAYMENTS
// ============================================================

class Receipts extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get receiptNumber => text()();
  TextColumn get employeeId => text().nullable().references(Employees, #id)();
  TextColumn get customerId => text().nullable().references(Customers, #id)();
  RealColumn get subtotal => real().withDefault(const Constant(0.0))();
  RealColumn get discountTotal => real().withDefault(const Constant(0.0))();
  RealColumn get taxTotal => real().withDefault(const Constant(0.0))();
  RealColumn get total => real().withDefault(const Constant(0.0))();
  TextColumn get currency => text().withDefault(const Constant('LAK'))();
  RealColumn get exchangeRate => real().withDefault(const Constant(1.0))();
  TextColumn get diningOption => text().withDefault(const Constant('dine_in'))();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ReceiptItems extends Table {
  TextColumn get id => text()();
  TextColumn get receiptId => text().references(Receipts, #id)();
  TextColumn get itemId => text().nullable().references(Items, #id)();
  TextColumn get variantId => text().nullable()();
  TextColumn get name => text()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  RealColumn get unitPrice => real().withDefault(const Constant(0.0))();
  RealColumn get discount => real().withDefault(const Constant(0.0))();
  RealColumn get tax => real().withDefault(const Constant(0.0))();
  RealColumn get total => real().withDefault(const Constant(0.0))();
  TextColumn get modifiers => text().withDefault(const Constant('[]'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get receiptId => text().references(Receipts, #id)();
  TextColumn get method => text()(); // cash, qr, card, other
  RealColumn get amount => real()();
  TextColumn get currency => text().withDefault(const Constant('LAK'))();
  TextColumn get reference => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// SHIFTS & CASH MANAGEMENT
// ============================================================

class Shifts extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get employeeId => text().references(Employees, #id)();
  DateTimeColumn get openedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get closedAt => dateTime().nullable()();
  RealColumn get openingCash => real().withDefault(const Constant(0.0))();
  RealColumn get closingCash => real().nullable()();
  RealColumn get expectedCash => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class CashMovements extends Table {
  TextColumn get id => text()();
  TextColumn get shiftId => text().references(Shifts, #id)();
  TextColumn get type => text()(); // in, out
  RealColumn get amount => real()();
  TextColumn get reason => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// INVENTORY
// ============================================================

class InventoryLevels extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get variantId => text().nullable()();
  TextColumn get storeId => text().references(Stores, #id)();
  RealColumn get quantity => real().withDefault(const Constant(0.0))();
  RealColumn get lowStockThreshold => real().withDefault(const Constant(0.0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class StockAdjustments extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get variantId => text().nullable()();
  RealColumn get quantityChange => real()();
  TextColumn get reason => text()();
  TextColumn get employeeId => text().nullable().references(Employees, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class InventoryCounts extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get status => text().withDefault(const Constant('in_progress'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class InventoryCountItems extends Table {
  TextColumn get id => text()();
  TextColumn get countId => text().references(InventoryCounts, #id)();
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get variantId => text().nullable()();
  RealColumn get expectedQty => real().withDefault(const Constant(0.0))();
  RealColumn get countedQty => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// PURCHASE ORDERS & SUPPLIERS
// ============================================================

class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseOrders extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get supplierId => text().nullable().references(Suppliers, #id)();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  RealColumn get total => real().withDefault(const Constant(0.0))();
  TextColumn get currency => text().withDefault(const Constant('LAK'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseOrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get poId => text().references(PurchaseOrders, #id)();
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get variantId => text().nullable()();
  RealColumn get quantity => real()();
  RealColumn get cost => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// TRANSFER ORDERS
// ============================================================

class TransferOrders extends Table {
  TextColumn get id => text()();
  TextColumn get fromStoreId => text().references(Stores, #id)();
  TextColumn get toStoreId => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class TransferOrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get transferId => text().references(TransferOrders, #id)();
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get variantId => text().nullable()();
  RealColumn get quantity => real()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// TAX
// ============================================================

class TaxRates extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  RealColumn get rate => real()();
  BoolColumn get isInclusive => boolean().withDefault(const Constant(false))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  TextColumn get country => text().withDefault(const Constant('LA'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ItemTaxRates extends Table {
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get taxRateId => text().references(TaxRates, #id)();

  @override
  Set<Column> get primaryKey => {itemId, taxRateId};
}

// ============================================================
// EXPENSES
// ============================================================

class ExpenseCategories extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get icon => text().withDefault(const Constant('receipt'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get categoryId => text().nullable().references(ExpenseCategories, #id)();
  TextColumn get description => text().withDefault(const Constant(''))();
  RealColumn get amount => real()();
  TextColumn get currency => text().withDefault(const Constant('LAK'))();
  DateTimeColumn get date => dateTime()();
  TextColumn get employeeId => text().nullable().references(Employees, #id)();
  TextColumn get receiptImagePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// RECIPES (Production / Composite Items)
// ============================================================

class Recipes extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get finishedItemId => text().references(Items, #id)();
  RealColumn get outputQuantity => real().withDefault(const Constant(1.0))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class RecipeItems extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text().references(Recipes, #id)();
  TextColumn get ingredientItemId => text().references(Items, #id)();
  RealColumn get quantity => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ProductionLogs extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get recipeId => text().references(Recipes, #id)();
  RealColumn get quantityProduced => real()();
  TextColumn get employeeId => text().nullable().references(Employees, #id)();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// AUDIT LOG
// ============================================================

class AuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get employeeId => text().nullable().references(Employees, #id)();
  TextColumn get action => text()(); // create, update, delete, login, logout, refund, etc.
  TextColumn get entityType => text()(); // item, receipt, employee, etc.
  TextColumn get entityId => text().nullable()();
  TextColumn get oldValues => text().nullable()();
  TextColumn get newValues => text().nullable()();
  TextColumn get ipAddress => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// SETTINGS
// ============================================================

class Settings extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get key => text()();
  TextColumn get value => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// SYNC
// ============================================================

class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entityTable => text()();
  TextColumn get rowId => text()();
  TextColumn get action => text()(); // create, update, delete
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncLog extends Table {
  TextColumn get id => text()();
  DateTimeColumn get lastSyncAt => dateTime()();
  TextColumn get direction => text()(); // push, pull
  IntColumn get recordsSynced => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// RESTAURANT — TABLES
// ============================================================

class RestaurantTables extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get seats => integer().withDefault(const Constant(4))();
  TextColumn get zone => text().withDefault(const Constant('main'))();
  IntColumn get posX => integer().withDefault(const Constant(0))();
  IntColumn get posY => integer().withDefault(const Constant(0))();
  TextColumn get status =>
      text().withDefault(const Constant('available'))(); // available, occupied, reserved
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// RESTAURANT — OPEN TICKETS
// ============================================================

class OpenTickets extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get employeeId =>
      text().nullable().references(Employees, #id)();
  TextColumn get customerId =>
      text().nullable().references(Customers, #id)();
  TextColumn get tableId =>
      text().nullable().references(RestaurantTables, #id)();
  TextColumn get ticketName => text().withDefault(const Constant(''))();
  TextColumn get diningOption =>
      text().withDefault(const Constant('dine_in'))();
  RealColumn get subtotal => real().withDefault(const Constant(0.0))();
  RealColumn get discountTotal => real().withDefault(const Constant(0.0))();
  RealColumn get taxTotal => real().withDefault(const Constant(0.0))();
  RealColumn get total => real().withDefault(const Constant(0.0))();
  TextColumn get status =>
      text().withDefault(const Constant('open'))(); // open, closed
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class OpenTicketItems extends Table {
  TextColumn get id => text()();
  TextColumn get ticketId => text().references(OpenTickets, #id)();
  TextColumn get itemId => text().nullable().references(Items, #id)();
  TextColumn get variantId => text().nullable()();
  TextColumn get name => text()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  RealColumn get unitPrice => real().withDefault(const Constant(0.0))();
  RealColumn get discount => real().withDefault(const Constant(0.0))();
  RealColumn get total => real().withDefault(const Constant(0.0))();
  TextColumn get modifiers =>
      text().withDefault(const Constant('[]'))();
  TextColumn get notes => text().nullable()();
  TextColumn get kdsStatus =>
      text().withDefault(const Constant('pending'))(); // pending, preparing, ready, served
  TextColumn get kdsStation => text().nullable()(); // kitchen, bar, dessert
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// RESTAURANT — KDS CATEGORY ROUTING
// ============================================================

class KdsRouting extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get station =>
      text().withDefault(const Constant('kitchen'))(); // kitchen, bar, dessert, etc.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
