import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';
import 'expense_repository.dart';
import 'report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ReportRepository(db);
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ExpenseRepository(db);
});

/// Date range state for reports.
class DateRangeState {
  final DateTime from;
  final DateTime to;
  final String label;

  const DateRangeState({
    required this.from,
    required this.to,
    required this.label,
  });
}

final dateRangeProvider = StateProvider<DateRangeState>((ref) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = todayStart.add(const Duration(days: 1));
  return DateRangeState(from: todayStart, to: todayEnd, label: 'today');
});

final salesSummaryProvider =
    FutureProvider.family<SalesSummary, (String storeId, DateTime from, DateTime to)>(
        (ref, params) {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getSalesSummary(
      storeId: params.$1, from: params.$2, to: params.$3);
});

final salesByItemProvider =
    FutureProvider.family<List<ItemSales>, (String storeId, DateTime from, DateTime to)>(
        (ref, params) {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getSalesByItem(
      storeId: params.$1, from: params.$2, to: params.$3);
});

final salesByCategoryProvider = FutureProvider.family<List<CategorySales>,
    (String storeId, DateTime from, DateTime to)>((ref, params) {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getSalesByCategory(
      storeId: params.$1, from: params.$2, to: params.$3);
});

final salesByEmployeeProvider = FutureProvider.family<List<EmployeeSales>,
    (String storeId, DateTime from, DateTime to)>((ref, params) {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getSalesByEmployee(
      storeId: params.$1, from: params.$2, to: params.$3);
});

final salesByPaymentProvider = FutureProvider.family<List<PaymentMethodSales>,
    (String storeId, DateTime from, DateTime to)>((ref, params) {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getSalesByPaymentMethod(
      storeId: params.$1, from: params.$2, to: params.$3);
});

final salesByHourProvider = FutureProvider.family<List<HourlySales>,
    (String storeId, DateTime from, DateTime to)>((ref, params) {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getSalesByHour(
      storeId: params.$1, from: params.$2, to: params.$3);
});

final taxReportProvider = FutureProvider.family<List<TaxReport>,
    (String storeId, DateTime from, DateTime to)>((ref, params) {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getTaxReport(
      storeId: params.$1, from: params.$2, to: params.$3);
});

final discountReportProvider = FutureProvider.family<DiscountReport,
    (String storeId, DateTime from, DateTime to)>((ref, params) {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getDiscountReport(
      storeId: params.$1, from: params.$2, to: params.$3);
});

final customerReportProvider = FutureProvider.family<List<CustomerReport>,
    (String storeId, DateTime from, DateTime to)>((ref, params) {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getCustomerReport(
      storeId: params.$1, from: params.$2, to: params.$3);
});

final inventoryReportProvider =
    FutureProvider.family<List<InventoryReport>, String>((ref, storeId) {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getInventoryReport(storeId: storeId);
});

final expenseSummaryProvider = FutureProvider.family<List<ExpenseSummary>,
    (String storeId, DateTime from, DateTime to)>((ref, params) {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getExpenseSummary(
      storeId: params.$1, from: params.$2, to: params.$3);
});

final profitAndLossProvider = FutureProvider.family<ProfitAndLoss,
    (String storeId, DateTime from, DateTime to)>((ref, params) {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getProfitAndLoss(
      storeId: params.$1, from: params.$2, to: params.$3);
});
