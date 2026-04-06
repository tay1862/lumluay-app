import 'package:flutter/foundation.dart';

import 'report_repository.dart';

class ReportExporter {
  /// Export sales by item to CSV string.
  static String itemSalesToCsv(List<ItemSales> data) {
    final buf = StringBuffer();
    buf.writeln('Item,Quantity,Total');
    for (final item in data) {
      buf.writeln(
          '${_escape(item.itemName)},${item.quantity},${item.total}');
    }
    return buf.toString();
  }

  /// Export sales by category to CSV string.
  static String categorySalesToCsv(List<CategorySales> data) {
    final buf = StringBuffer();
    buf.writeln('Category,Item Count,Total');
    for (final cat in data) {
      buf.writeln(
          '${_escape(cat.categoryName)},${cat.itemCount},${cat.total}');
    }
    return buf.toString();
  }

  /// Export sales by employee to CSV string.
  static String employeeSalesToCsv(List<EmployeeSales> data) {
    final buf = StringBuffer();
    buf.writeln('Employee,Receipt Count,Total');
    for (final emp in data) {
      buf.writeln(
          '${_escape(emp.employeeName)},${emp.receiptCount},${emp.total}');
    }
    return buf.toString();
  }

  /// Export sales by payment method to CSV string.
  static String paymentSalesToCsv(List<PaymentMethodSales> data) {
    final buf = StringBuffer();
    buf.writeln('Method,Count,Total');
    for (final pm in data) {
      buf.writeln('${_escape(pm.method)},${pm.count},${pm.total}');
    }
    return buf.toString();
  }

  /// Export sales by hour to CSV string.
  static String hourlySalesToCsv(List<HourlySales> data) {
    final buf = StringBuffer();
    buf.writeln('Hour,Count,Total');
    for (final h in data) {
      buf.writeln(
          '${h.hour.toString().padLeft(2, '0')}:00,${h.count},${h.total}');
    }
    return buf.toString();
  }

  /// Export inventory report to CSV string.
  static String inventoryToCsv(List<InventoryReport> data) {
    final buf = StringBuffer();
    buf.writeln('Item,Quantity,Low Stock Threshold,Cost Value');
    for (final inv in data) {
      buf.writeln(
          '${_escape(inv.itemName)},${inv.quantity},${inv.lowStockThreshold},${inv.costValue}');
    }
    return buf.toString();
  }

  /// Export customer report to CSV string.
  static String customerReportToCsv(List<CustomerReport> data) {
    final buf = StringBuffer();
    buf.writeln('Customer,Visits,Total Spent');
    for (final c in data) {
      buf.writeln(
          '${_escape(c.customerName)},${c.visitCount},${c.totalSpent}');
    }
    return buf.toString();
  }

  /// Trigger download of CSV on web.
  static void downloadCsv(String csv, String filename) {
    if (kIsWeb) {
      // On web, use data URI download
      // ignore: avoid_dynamic_calls
      _webDownload(csv, filename);
    }
  }

  static void _webDownload(String content, String filename) {
    // Web download via dart:html would be here; for now just debug print
    debugPrint('CSV Export: $filename (${content.length} chars)');
  }

  static String _escape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
