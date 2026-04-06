import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class SalesSummary {
  final int receiptCount;
  final double totalSales;
  final double totalDiscount;
  final double totalTax;
  final double netSales;

  const SalesSummary({
    required this.receiptCount,
    required this.totalSales,
    required this.totalDiscount,
    required this.totalTax,
    required this.netSales,
  });
}

class ItemSales {
  final String itemName;
  final double quantity;
  final double total;

  const ItemSales({
    required this.itemName,
    required this.quantity,
    required this.total,
  });
}

class CategorySales {
  final String categoryName;
  final double total;
  final int itemCount;

  const CategorySales({
    required this.categoryName,
    required this.total,
    required this.itemCount,
  });
}

class EmployeeSales {
  final String employeeName;
  final int receiptCount;
  final double total;

  const EmployeeSales({
    required this.employeeName,
    required this.receiptCount,
    required this.total,
  });
}

class PaymentMethodSales {
  final String method;
  final double total;
  final int count;

  const PaymentMethodSales({
    required this.method,
    required this.total,
    required this.count,
  });
}

class HourlySales {
  final int hour;
  final double total;
  final int count;

  const HourlySales({
    required this.hour,
    required this.total,
    required this.count,
  });
}

class TaxReport {
  final String taxName;
  final double rate;
  final double taxCollected;

  const TaxReport({
    required this.taxName,
    required this.rate,
    required this.taxCollected,
  });
}

class DiscountReport {
  final int receiptCount;
  final double totalDiscount;
  final double avgDiscount;

  const DiscountReport({
    required this.receiptCount,
    required this.totalDiscount,
    required this.avgDiscount,
  });
}

class CustomerReport {
  final String customerName;
  final int visitCount;
  final double totalSpent;

  const CustomerReport({
    required this.customerName,
    required this.visitCount,
    required this.totalSpent,
  });
}

class InventoryReport {
  final String itemName;
  final double quantity;
  final double lowStockThreshold;
  final double costValue;

  const InventoryReport({
    required this.itemName,
    required this.quantity,
    required this.lowStockThreshold,
    required this.costValue,
  });
}

class ExpenseSummary {
  final String category;
  final double total;
  final int count;

  const ExpenseSummary({
    required this.category,
    required this.total,
    required this.count,
  });
}

class ProfitAndLoss {
  final double revenue;
  final double cogs;
  final double expenses;
  final double grossProfit;
  final double netProfit;

  const ProfitAndLoss({
    required this.revenue,
    required this.cogs,
    required this.expenses,
    required this.grossProfit,
    required this.netProfit,
  });
}

class ReportRepository {
  final AppDatabase _db;

  ReportRepository(this._db);

  /// Sales summary for a date range.
  Future<SalesSummary> getSalesSummary({
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) async {
    final query = _db.select(_db.receipts)
      ..where((t) =>
          t.storeId.equals(storeId) &
          t.status.equals('completed') &
          t.createdAt.isBiggerOrEqualValue(from) &
          t.createdAt.isSmallerOrEqualValue(to));

    final receipts = await query.get();

    double totalSales = 0;
    double totalDiscount = 0;
    double totalTax = 0;

    for (final r in receipts) {
      totalSales += r.total;
      totalDiscount += r.discountTotal;
      totalTax += r.taxTotal;
    }

    return SalesSummary(
      receiptCount: receipts.length,
      totalSales: totalSales,
      totalDiscount: totalDiscount,
      totalTax: totalTax,
      netSales: totalSales - totalDiscount,
    );
  }

  /// Sales by item for a date range.
  Future<List<ItemSales>> getSalesByItem({
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) async {
    final query = _db.select(_db.receiptItems).join([
      innerJoin(
          _db.receipts, _db.receipts.id.equalsExp(_db.receiptItems.receiptId)),
    ])
      ..where(_db.receipts.storeId.equals(storeId) &
          _db.receipts.status.equals('completed') &
          _db.receipts.createdAt.isBiggerOrEqualValue(from) &
          _db.receipts.createdAt.isSmallerOrEqualValue(to));

    final rows = await query.get();

    // Group by item name
    final map = <String, (double qty, double total)>{};
    for (final row in rows) {
      final ri = row.readTable(_db.receiptItems);
      final existing = map[ri.name];
      if (existing != null) {
        map[ri.name] = (existing.$1 + ri.quantity, existing.$2 + ri.total);
      } else {
        map[ri.name] = (ri.quantity, ri.total);
      }
    }

    final result = map.entries
        .map((e) => ItemSales(
            itemName: e.key, quantity: e.value.$1, total: e.value.$2))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return result;
  }

  /// Sales by category for a date range.
  Future<List<CategorySales>> getSalesByCategory({
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) async {
    final query = _db.select(_db.receiptItems).join([
      innerJoin(
          _db.receipts, _db.receipts.id.equalsExp(_db.receiptItems.receiptId)),
      leftOuterJoin(_db.items, _db.items.id.equalsExp(_db.receiptItems.itemId)),
      leftOuterJoin(
          _db.categories, _db.categories.id.equalsExp(_db.items.categoryId)),
    ])
      ..where(_db.receipts.storeId.equals(storeId) &
          _db.receipts.status.equals('completed') &
          _db.receipts.createdAt.isBiggerOrEqualValue(from) &
          _db.receipts.createdAt.isSmallerOrEqualValue(to));

    final rows = await query.get();

    final map = <String, (double total, int count)>{};
    for (final row in rows) {
      final cat = row.readTableOrNull(_db.categories);
      final ri = row.readTable(_db.receiptItems);
      final catName = cat?.name ?? 'Uncategorized';
      final existing = map[catName];
      if (existing != null) {
        map[catName] = (existing.$1 + ri.total, existing.$2 + 1);
      } else {
        map[catName] = (ri.total, 1);
      }
    }

    final result = map.entries
        .map((e) => CategorySales(
            categoryName: e.key, total: e.value.$1, itemCount: e.value.$2))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return result;
  }

  /// Sales by employee for a date range.
  Future<List<EmployeeSales>> getSalesByEmployee({
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) async {
    final query = _db.select(_db.receipts).join([
      leftOuterJoin(
          _db.employees, _db.employees.id.equalsExp(_db.receipts.employeeId)),
    ])
      ..where(_db.receipts.storeId.equals(storeId) &
          _db.receipts.status.equals('completed') &
          _db.receipts.createdAt.isBiggerOrEqualValue(from) &
          _db.receipts.createdAt.isSmallerOrEqualValue(to));

    final rows = await query.get();

    final map = <String, (int count, double total)>{};
    for (final row in rows) {
      final emp = row.readTableOrNull(_db.employees);
      final receipt = row.readTable(_db.receipts);
      final name = emp?.name ?? 'Unknown';
      final existing = map[name];
      if (existing != null) {
        map[name] = (existing.$1 + 1, existing.$2 + receipt.total);
      } else {
        map[name] = (1, receipt.total);
      }
    }

    final result = map.entries
        .map((e) => EmployeeSales(
            employeeName: e.key,
            receiptCount: e.value.$1,
            total: e.value.$2))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return result;
  }

  /// Sales by payment method for a date range.
  Future<List<PaymentMethodSales>> getSalesByPaymentMethod({
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) async {
    final query = _db.select(_db.payments).join([
      innerJoin(
          _db.receipts, _db.receipts.id.equalsExp(_db.payments.receiptId)),
    ])
      ..where(_db.receipts.storeId.equals(storeId) &
          _db.receipts.status.equals('completed') &
          _db.receipts.createdAt.isBiggerOrEqualValue(from) &
          _db.receipts.createdAt.isSmallerOrEqualValue(to));

    final rows = await query.get();

    final map = <String, (double total, int count)>{};
    for (final row in rows) {
      final payment = row.readTable(_db.payments);
      final existing = map[payment.method];
      if (existing != null) {
        map[payment.method] =
            (existing.$1 + payment.amount, existing.$2 + 1);
      } else {
        map[payment.method] = (payment.amount, 1);
      }
    }

    final result = map.entries
        .map((e) => PaymentMethodSales(
            method: e.key, total: e.value.$1, count: e.value.$2))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return result;
  }

  /// Sales by hour for a date range.
  Future<List<HourlySales>> getSalesByHour({
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) async {
    final query = _db.select(_db.receipts)
      ..where((t) =>
          t.storeId.equals(storeId) &
          t.status.equals('completed') &
          t.createdAt.isBiggerOrEqualValue(from) &
          t.createdAt.isSmallerOrEqualValue(to));

    final receipts = await query.get();

    final map = <int, (double total, int count)>{};
    for (final r in receipts) {
      final hour = r.createdAt.hour;
      final existing = map[hour];
      if (existing != null) {
        map[hour] = (existing.$1 + r.total, existing.$2 + 1);
      } else {
        map[hour] = (r.total, 1);
      }
    }

    final result = List.generate(24, (hour) {
      final data = map[hour];
      return HourlySales(
        hour: hour,
        total: data?.$1 ?? 0,
        count: data?.$2 ?? 0,
      );
    });

    return result;
  }

  /// Tax report for a date range.
  Future<List<TaxReport>> getTaxReport({
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) async {
    // Get tax rates
    final taxRates = await (_db.select(_db.taxRates)
          ..where((t) => t.storeId.equals(storeId)))
        .get();

    if (taxRates.isEmpty) {
      // If no tax rates defined, return aggregate from receipts
      final query = _db.select(_db.receipts)
        ..where((t) =>
            t.storeId.equals(storeId) &
            t.status.equals('completed') &
            t.createdAt.isBiggerOrEqualValue(from) &
            t.createdAt.isSmallerOrEqualValue(to));
      final receipts = await query.get();
      double totalTax = 0;
      for (final r in receipts) {
        totalTax += r.taxTotal;
      }
      if (totalTax > 0) {
        return [TaxReport(taxName: 'Tax', rate: 0, taxCollected: totalTax)];
      }
      return [];
    }

    return taxRates
        .map((tr) => TaxReport(
              taxName: tr.name,
              rate: tr.rate,
              taxCollected: 0, // Would need receipt-level tax rate tracking
            ))
        .toList();
  }

  /// Discount report for a date range.
  Future<DiscountReport> getDiscountReport({
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) async {
    final query = _db.select(_db.receipts)
      ..where((t) =>
          t.storeId.equals(storeId) &
          t.status.equals('completed') &
          t.discountTotal.isBiggerThanValue(0) &
          t.createdAt.isBiggerOrEqualValue(from) &
          t.createdAt.isSmallerOrEqualValue(to));

    final receipts = await query.get();

    double totalDiscount = 0;
    for (final r in receipts) {
      totalDiscount += r.discountTotal;
    }

    return DiscountReport(
      receiptCount: receipts.length,
      totalDiscount: totalDiscount,
      avgDiscount: receipts.isEmpty ? 0 : totalDiscount / receipts.length,
    );
  }

  /// Customer report — top customers by spend.
  Future<List<CustomerReport>> getCustomerReport({
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) async {
    final query = _db.select(_db.receipts).join([
      innerJoin(
          _db.customers, _db.customers.id.equalsExp(_db.receipts.customerId)),
    ])
      ..where(_db.receipts.storeId.equals(storeId) &
          _db.receipts.status.equals('completed') &
          _db.receipts.createdAt.isBiggerOrEqualValue(from) &
          _db.receipts.createdAt.isSmallerOrEqualValue(to));

    final rows = await query.get();

    final map = <String, (int count, double total)>{};
    for (final row in rows) {
      final cust = row.readTable(_db.customers);
      final receipt = row.readTable(_db.receipts);
      final existing = map[cust.name];
      if (existing != null) {
        map[cust.name] = (existing.$1 + 1, existing.$2 + receipt.total);
      } else {
        map[cust.name] = (1, receipt.total);
      }
    }

    final result = map.entries
        .map((e) => CustomerReport(
            customerName: e.key,
            visitCount: e.value.$1,
            totalSpent: e.value.$2))
        .toList()
      ..sort((a, b) => b.totalSpent.compareTo(a.totalSpent));

    return result;
  }

  /// Inventory report — stock levels and valuation.
  Future<List<InventoryReport>> getInventoryReport({
    required String storeId,
  }) async {
    final query = _db.select(_db.inventoryLevels).join([
      innerJoin(_db.items, _db.items.id.equalsExp(_db.inventoryLevels.itemId)),
    ])
      ..where(_db.inventoryLevels.storeId.equals(storeId));

    final rows = await query.get();

    return rows.map((row) {
      final inv = row.readTable(_db.inventoryLevels);
      final item = row.readTable(_db.items);
      return InventoryReport(
        itemName: item.name,
        quantity: inv.quantity,
        lowStockThreshold: inv.lowStockThreshold,
        costValue: inv.quantity * item.cost,
      );
    }).toList()
      ..sort((a, b) => a.quantity.compareTo(b.quantity));
  }

  /// Expense summary by category for a date range.
  Future<List<ExpenseSummary>> getExpenseSummary({
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) async {
    final query = _db.select(_db.expenses).join([
      leftOuterJoin(_db.expenseCategories,
          _db.expenseCategories.id.equalsExp(_db.expenses.categoryId)),
    ])
      ..where(_db.expenses.storeId.equals(storeId) &
          _db.expenses.date.isBiggerOrEqualValue(from) &
          _db.expenses.date.isSmallerOrEqualValue(to));

    final rows = await query.get();

    final map = <String, (double total, int count)>{};
    for (final row in rows) {
      final cat = row.readTableOrNull(_db.expenseCategories);
      final expense = row.readTable(_db.expenses);
      final catName = cat?.name ?? 'Uncategorized';
      final existing = map[catName];
      if (existing != null) {
        map[catName] = (existing.$1 + expense.amount, existing.$2 + 1);
      } else {
        map[catName] = (expense.amount, 1);
      }
    }

    return map.entries
        .map((e) => ExpenseSummary(
            category: e.key, total: e.value.$1, count: e.value.$2))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
  }

  /// Profit & Loss for a date range.
  Future<ProfitAndLoss> getProfitAndLoss({
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) async {
    // Revenue
    final salesQuery = _db.select(_db.receipts)
      ..where((t) =>
          t.storeId.equals(storeId) &
          t.status.equals('completed') &
          t.createdAt.isBiggerOrEqualValue(from) &
          t.createdAt.isSmallerOrEqualValue(to));
    final receipts = await salesQuery.get();
    double revenue = 0;
    for (final r in receipts) {
      revenue += r.total;
    }

    // COGS — sum(cost × quantity) for receipt items
    final cogsQuery = _db.select(_db.receiptItems).join([
      innerJoin(
          _db.receipts, _db.receipts.id.equalsExp(_db.receiptItems.receiptId)),
      leftOuterJoin(
          _db.items, _db.items.id.equalsExp(_db.receiptItems.itemId)),
    ])
      ..where(_db.receipts.storeId.equals(storeId) &
          _db.receipts.status.equals('completed') &
          _db.receipts.createdAt.isBiggerOrEqualValue(from) &
          _db.receipts.createdAt.isSmallerOrEqualValue(to));
    final cogsRows = await cogsQuery.get();
    double cogs = 0;
    for (final row in cogsRows) {
      final item = row.readTableOrNull(_db.items);
      final ri = row.readTable(_db.receiptItems);
      if (item != null) {
        cogs += item.cost * ri.quantity;
      }
    }

    // Expenses
    final expQuery = _db.select(_db.expenses)
      ..where((t) =>
          t.storeId.equals(storeId) &
          t.date.isBiggerOrEqualValue(from) &
          t.date.isSmallerOrEqualValue(to));
    final expRows = await expQuery.get();
    double expenses = 0;
    for (final e in expRows) {
      expenses += e.amount;
    }

    final grossProfit = revenue - cogs;
    final netProfit = grossProfit - expenses;

    return ProfitAndLoss(
      revenue: revenue,
      cogs: cogs,
      expenses: expenses,
      grossProfit: grossProfit,
      netProfit: netProfit,
    );
  }
}
