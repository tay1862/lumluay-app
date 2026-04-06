import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import 'inventory_repository.dart';
import 'production_repository.dart';
import 'purchase_order_repository.dart';
import 'transfer_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return InventoryRepository(db);
});

final purchaseOrderRepositoryProvider =
    Provider<PurchaseOrderRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PurchaseOrderRepository(db);
});

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TransferRepository(db);
});

/// Watch stock levels for a store (with item info).
final stockLevelsProvider =
    StreamProvider.family<List<InventoryStock>, String>((ref, storeId) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.watchStockLevels(storeId);
});

/// Watch low-stock items.
final lowStockProvider =
    StreamProvider.family<List<InventoryStock>, String>((ref, storeId) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.watchLowStock(storeId);
});

/// Watch stock adjustments for a store.
final stockAdjustmentsProvider =
    StreamProvider.family<List<StockAdjustment>, String>((ref, storeId) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.watchAdjustments(storeId);
});

/// Watch inventory counts for a store.
final inventoryCountsProvider =
    StreamProvider.family<List<InventoryCount>, String>((ref, storeId) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.watchInventoryCounts(storeId);
});

/// Watch count items for a specific count session.
final countItemsProvider =
    StreamProvider.family<List<InventoryCountItem>, String>((ref, countId) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.watchCountItems(countId);
});

/// Get inventory valuation.
final inventoryValuationProvider =
    FutureProvider.family<double, String>((ref, storeId) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getInventoryValuation(storeId);
});

// ── Purchase Orders ──

final suppliersProvider =
    StreamProvider.family<List<Supplier>, String>((ref, storeId) {
  final repo = ref.watch(purchaseOrderRepositoryProvider);
  return repo.watchSuppliers(storeId);
});

final purchaseOrdersProvider =
    StreamProvider.family<List<PurchaseOrderWithSupplier>, String>(
        (ref, storeId) {
  final repo = ref.watch(purchaseOrderRepositoryProvider);
  return repo.watchPurchaseOrders(storeId);
});

final poItemsProvider =
    StreamProvider.family<List<POItemWithName>, String>((ref, poId) {
  final repo = ref.watch(purchaseOrderRepositoryProvider);
  return repo.watchPOItems(poId);
});

// ── Transfers ──

final transferOrdersProvider =
    StreamProvider.family<List<TransferOrder>, String>((ref, storeId) {
  final repo = ref.watch(transferRepositoryProvider);
  return repo.watchTransfers(storeId);
});

final transferItemsProvider =
    StreamProvider.family<List<TransferItemWithName>, String>(
        (ref, transferId) {
  final repo = ref.watch(transferRepositoryProvider);
  return repo.watchTransferItems(transferId);
});

// ── Production ──

final productionRepositoryProvider = Provider<ProductionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ProductionRepository(db);
});

final recipesProvider =
    StreamProvider.family<List<RecipeWithItem>, String>((ref, storeId) {
  final repo = ref.watch(productionRepositoryProvider);
  return repo.watchRecipes(storeId);
});

final recipeIngredientsProvider =
    StreamProvider.family<List<RecipeIngredient>, String>((ref, recipeId) {
  final repo = ref.watch(productionRepositoryProvider);
  return repo.watchIngredients(recipeId);
});

final productionLogsProvider =
    StreamProvider.family<List<ProductionLogWithInfo>, String>(
        (ref, storeId) {
  final repo = ref.watch(productionRepositoryProvider);
  return repo.watchProductionLogs(storeId);
});
