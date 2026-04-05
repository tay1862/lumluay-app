import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
  TaxRates,
  ItemTaxRates,
  ExpenseCategories,
  Expenses,
  AuditLogs,
  Settings,
  SyncQueue,
  SyncLog,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => AppConstants.dbVersion;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations go here
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.dbName));
    return NativeDatabase.createInBackground(file);
  });
}
