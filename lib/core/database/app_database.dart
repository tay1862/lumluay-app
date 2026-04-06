import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../constants/app_constants.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Stores,
  Categories,
  Items,
  VariantGroups,
  Variants,
  ModifierGroups,
  Modifiers,
  ItemModifierGroups,
  Customers,
  LoyaltySettings,
  LoyaltyTransactions,
  EmployeeRoles,
  Employees,
  TimeEntries,
  Receipts,
  ReceiptItems,
  Payments,
  Shifts,
  CashMovements,
  InventoryLevels,
  StockAdjustments,
  InventoryCounts,
  InventoryCountItems,
  Suppliers,
  PurchaseOrders,
  PurchaseOrderItems,
  TransferOrders,
  TransferOrderItems,
  Recipes,
  RecipeItems,
  ProductionLogs,
  TaxRates,
  ItemTaxRates,
  ExpenseCategories,
  Expenses,
  AuditLogs,
  Settings,
  SyncQueue,
  SyncLog,
  RestaurantTables,
  OpenTickets,
  OpenTicketItems,
  KdsRouting,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(driftDatabase(
          name: AppConstants.dbName,
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.dart.js'),
          ),
        ));

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => AppConstants.dbVersion;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Performance indexes for frequently queried columns
        await customStatement('CREATE INDEX idx_items_store ON items(store_id)');
        await customStatement('CREATE INDEX idx_items_category ON items(category_id)');
        await customStatement('CREATE INDEX idx_items_barcode ON items(barcode)');
        await customStatement('CREATE INDEX idx_items_sku ON items(sku)');
        await customStatement('CREATE INDEX idx_items_active ON items(store_id, active)');
        await customStatement('CREATE INDEX idx_categories_store ON categories(store_id)');
        await customStatement('CREATE INDEX idx_receipts_store ON receipts(store_id)');
        await customStatement('CREATE INDEX idx_receipts_created ON receipts(store_id, created_at)');
        await customStatement('CREATE INDEX idx_receipts_status ON receipts(store_id, status)');
        await customStatement('CREATE INDEX idx_receipts_employee ON receipts(employee_id)');
        await customStatement('CREATE INDEX idx_receipts_customer ON receipts(customer_id)');
        await customStatement('CREATE INDEX idx_receipt_items_receipt ON receipt_items(receipt_id)');
        await customStatement('CREATE INDEX idx_payments_receipt ON payments(receipt_id)');
        await customStatement('CREATE INDEX idx_employees_store ON employees(store_id)');
        await customStatement('CREATE INDEX idx_shifts_store ON shifts(store_id)');
        await customStatement('CREATE INDEX idx_shifts_employee ON shifts(employee_id)');
        await customStatement('CREATE INDEX idx_cash_movements_shift ON cash_movements(shift_id)');
        await customStatement('CREATE INDEX idx_inventory_item ON inventory_levels(item_id, store_id)');
        await customStatement('CREATE INDEX idx_stock_adj_store ON stock_adjustments(store_id, created_at)');
        await customStatement('CREATE INDEX idx_customers_store ON customers(store_id)');
        await customStatement('CREATE INDEX idx_customers_phone ON customers(phone)');
        await customStatement('CREATE INDEX idx_audit_store ON audit_logs(store_id, created_at)');
        await customStatement('CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id)');
        await customStatement('CREATE INDEX idx_settings_store ON settings(store_id, key)');
        await customStatement('CREATE INDEX idx_sync_queue_status ON sync_queue(status)');
        await customStatement('CREATE INDEX idx_open_tickets_store ON open_tickets(store_id)');
        await customStatement('CREATE INDEX idx_open_ticket_items_ticket ON open_ticket_items(ticket_id)');
        await customStatement('CREATE INDEX idx_restaurant_tables_store ON restaurant_tables(store_id)');
        await customStatement('CREATE INDEX idx_expenses_store ON expenses(store_id, date)');
        await customStatement('CREATE INDEX idx_variants_item ON variants(item_id)');
        await customStatement('CREATE INDEX idx_loyalty_tx_customer ON loyalty_transactions(customer_id)');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations go here
      },
    );
  }
}
