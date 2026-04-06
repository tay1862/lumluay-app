import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import 'cart_notifier.dart';
import 'cart_state.dart';
import 'receipt_printer_service.dart';
import 'sales_repository.dart';
import 'tax_service.dart';

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SalesRepository(db);
});

final taxServiceProvider = Provider<TaxService>((ref) {
  final db = ref.watch(databaseProvider);
  return TaxService(db);
});

/// Watch receipts for a store (reactive stream)
final receiptsStreamProvider =
    StreamProvider.family<List<Receipt>, String>((ref, storeId) {
  final repo = ref.watch(salesRepositoryProvider);
  return repo.watchReceipts(storeId);
});

/// Fetch receipt items for a specific receipt
final receiptItemsProvider =
    FutureProvider.family<List<ReceiptItem>, String>((ref, receiptId) {
  final repo = ref.watch(salesRepositoryProvider);
  return repo.getReceiptItems(receiptId);
});

/// Fetch payments for a specific receipt
final receiptPaymentsProvider =
    FutureProvider.family<List<Payment>, String>((ref, receiptId) {
  final repo = ref.watch(salesRepositoryProvider);
  return repo.getPayments(receiptId);
});

/// Fetch a store by ID
final storeProvider =
    FutureProvider.family<Store?, String>((ref, storeId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.stores)..where((t) => t.id.equals(storeId)))
      .getSingleOrNull();
});

/// Build full ReceiptData for printing/sharing
final receiptDataProvider =
    FutureProvider.family<ReceiptData?, String>((ref, receiptId) async {
  final db = ref.watch(databaseProvider);

  final receipt = await (db.select(db.receipts)
        ..where((t) => t.id.equals(receiptId)))
      .getSingleOrNull();
  if (receipt == null) return null;

  final store = await (db.select(db.stores)
        ..where((t) => t.id.equals(receipt.storeId)))
      .getSingleOrNull();
  if (store == null) return null;

  final items = await (db.select(db.receiptItems)
        ..where((t) => t.receiptId.equals(receiptId)))
      .get();

  final payments = await (db.select(db.payments)
        ..where((t) => t.receiptId.equals(receiptId)))
      .get();

  String? employeeName;
  if (receipt.employeeId != null) {
    final emp = await (db.select(db.employees)
          ..where((t) => t.id.equals(receipt.employeeId!)))
        .getSingleOrNull();
    employeeName = emp?.name;
  }

  String? customerName;
  if (receipt.customerId != null) {
    final cust = await (db.select(db.customers)
          ..where((t) => t.id.equals(receipt.customerId!)))
        .getSingleOrNull();
    customerName = cust?.name;
  }

  return ReceiptData(
    receipt: receipt,
    store: store,
    items: items,
    payments: payments,
    employeeName: employeeName,
    customerName: customerName,
  );
});
