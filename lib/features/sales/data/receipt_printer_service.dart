import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';

/// Data container for all receipt information needed for printing.
class ReceiptData {
  final Receipt receipt;
  final Store store;
  final List<ReceiptItem> items;
  final List<Payment> payments;
  final String? employeeName;
  final String? customerName;

  const ReceiptData({
    required this.receipt,
    required this.store,
    required this.items,
    required this.payments,
    this.employeeName,
    this.customerName,
  });
}

/// Generates PDF receipts and handles printing.
class ReceiptPrinterService {
  static final _currencyFmt = NumberFormat('#,##0', 'en_US');
  static final _dateFmt = DateFormat('dd/MM/yyyy HH:mm');

  /// Build a PDF document from receipt data.
  static Future<Uint8List> generatePdf(ReceiptData data) async {
    final doc = pw.Document();
    final currency = data.store.currency;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(8),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Store name
            pw.Text(
              data.store.name,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            if (data.store.address.isNotEmpty)
              pw.Text(data.store.address,
                  style: const pw.TextStyle(fontSize: 8)),
            if (data.store.phone.isNotEmpty)
              pw.Text(data.store.phone,
                  style: const pw.TextStyle(fontSize: 8)),
            pw.SizedBox(height: 8),

            // Receipt info
            pw.Divider(thickness: 0.5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Receipt #',
                    style: const pw.TextStyle(fontSize: 8)),
                pw.Text(data.receipt.receiptNumber,
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Date',
                    style: const pw.TextStyle(fontSize: 8)),
                pw.Text(_dateFmt.format(data.receipt.createdAt),
                    style: const pw.TextStyle(fontSize: 8)),
              ],
            ),
            if (data.employeeName != null)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Cashier',
                      style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(data.employeeName!,
                      style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            if (data.customerName != null)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Customer',
                      style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(data.customerName!,
                      style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            pw.SizedBox(height: 4),
            pw.Divider(thickness: 0.5),

            // Items header
            pw.Row(
              children: [
                pw.Expanded(
                    flex: 4,
                    child: pw.Text('Item',
                        style: pw.TextStyle(
                            fontSize: 8, fontWeight: pw.FontWeight.bold))),
                pw.SizedBox(
                    width: 30,
                    child: pw.Text('Qty',
                        style: pw.TextStyle(
                            fontSize: 8, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.right)),
                pw.SizedBox(
                    width: 50,
                    child: pw.Text('Price',
                        style: pw.TextStyle(
                            fontSize: 8, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.right)),
                pw.SizedBox(
                    width: 50,
                    child: pw.Text('Total',
                        style: pw.TextStyle(
                            fontSize: 8, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.right)),
              ],
            ),
            pw.Divider(thickness: 0.3),

            // Items
            ...data.items.map((item) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 1),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                          flex: 4,
                          child: pw.Text(item.name,
                              style: const pw.TextStyle(fontSize: 8))),
                      pw.SizedBox(
                          width: 30,
                          child: pw.Text(
                              item.quantity == item.quantity.roundToDouble()
                                  ? item.quantity.toInt().toString()
                                  : item.quantity.toString(),
                              style: const pw.TextStyle(fontSize: 8),
                              textAlign: pw.TextAlign.right)),
                      pw.SizedBox(
                          width: 50,
                          child: pw.Text(
                              _currencyFmt.format(item.unitPrice),
                              style: const pw.TextStyle(fontSize: 8),
                              textAlign: pw.TextAlign.right)),
                      pw.SizedBox(
                          width: 50,
                          child: pw.Text(
                              _currencyFmt.format(item.total),
                              style: const pw.TextStyle(fontSize: 8),
                              textAlign: pw.TextAlign.right)),
                    ],
                  ),
                )),
            pw.Divider(thickness: 0.5),

            // Totals
            _pdfTotalRow('Subtotal', data.receipt.subtotal, currency),
            if (data.receipt.discountTotal > 0)
              _pdfTotalRow(
                  'Discount', -data.receipt.discountTotal, currency),
            if (data.receipt.taxTotal > 0)
              _pdfTotalRow('Tax', data.receipt.taxTotal, currency),
            pw.SizedBox(height: 2),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                    '$currency ${_currencyFmt.format(data.receipt.total)}',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.Divider(thickness: 0.5),

            // Payments
            ...data.payments.map((p) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(_paymentMethodLabel(p.method),
                        style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(
                        '${p.currency} ${_currencyFmt.format(p.amount)}',
                        style: const pw.TextStyle(fontSize: 8)),
                  ],
                )),

            // Change
            if (_calculateChange(data) > 0) ...[
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Change',
                      style: pw.TextStyle(
                          fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      '$currency ${_currencyFmt.format(_calculateChange(data))}',
                      style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            ],

            pw.SizedBox(height: 12),

            // Barcode
            pw.BarcodeWidget(
              barcode: pw.Barcode.code128(),
              data: data.receipt.receiptNumber,
              width: 140,
              height: 36,
              textStyle: const pw.TextStyle(fontSize: 7),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Thank you!',
                style: pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );

    return doc.save();
  }

  /// Print the receipt using the system print dialog.
  static Future<bool> printReceipt(ReceiptData data) async {
    final pdfBytes = await generatePdf(data);
    return Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
      name: 'Receipt-${data.receipt.receiptNumber}',
      format: PdfPageFormat.roll80,
    );
  }

  /// Share/export the receipt as PDF.
  static Future<void> shareReceipt(ReceiptData data) async {
    final pdfBytes = await generatePdf(data);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Receipt-${data.receipt.receiptNumber}.pdf',
    );
  }

  /// Generate ESC/POS thermal receipt commands (raw bytes).
  /// Can be sent to a Bluetooth/USB/WiFi thermal printer.
  static Uint8List generateEscPos(ReceiptData data, {int paperWidth = 48}) {
    final buf = BytesBuilder();
    final currency = data.store.currency;

    // ESC/POS commands
    const esc = 0x1B;
    const gs = 0x1D;

    // Initialize printer
    buf.add([esc, 0x40]); // ESC @ — initialize

    // Center align
    buf.add([esc, 0x61, 0x01]); // ESC a 1 — center

    // Store name (double width+height)
    buf.add([gs, 0x21, 0x11]); // GS ! 0x11 — double w+h
    buf.add(_encode(data.store.name));
    buf.add([0x0A]); // line feed
    buf.add([gs, 0x21, 0x00]); // GS ! 0x00 — normal

    if (data.store.address.isNotEmpty) {
      buf.add(_encode(data.store.address));
      buf.add([0x0A]);
    }
    if (data.store.phone.isNotEmpty) {
      buf.add(_encode(data.store.phone));
      buf.add([0x0A]);
    }

    // Separator
    buf.add(_encode('-' * paperWidth));
    buf.add([0x0A]);

    // Left align
    buf.add([esc, 0x61, 0x00]); // ESC a 0 — left

    // Receipt info
    buf.add(_encode(_padLine('Receipt #', data.receipt.receiptNumber, paperWidth)));
    buf.add([0x0A]);
    buf.add(_encode(_padLine('Date', _dateFmt.format(data.receipt.createdAt), paperWidth)));
    buf.add([0x0A]);
    if (data.employeeName != null) {
      buf.add(_encode(_padLine('Cashier', data.employeeName!, paperWidth)));
      buf.add([0x0A]);
    }

    // Separator
    buf.add(_encode('-' * paperWidth));
    buf.add([0x0A]);

    // Items
    for (final item in data.items) {
      final qty = item.quantity == item.quantity.roundToDouble()
          ? item.quantity.toInt().toString()
          : item.quantity.toString();
      final price = _currencyFmt.format(item.total);

      // Item name on first line
      buf.add(_encode(item.name));
      buf.add([0x0A]);

      // Qty x Price = Total on second line (indented)
      final detail =
          '  $qty x ${_currencyFmt.format(item.unitPrice)}';
      buf.add(_encode(_padLine(detail, price, paperWidth)));
      buf.add([0x0A]);
    }

    // Separator
    buf.add(_encode('=' * paperWidth));
    buf.add([0x0A]);

    // Totals
    buf.add(_encode(_padLine(
        'Subtotal', '$currency ${_currencyFmt.format(data.receipt.subtotal)}', paperWidth)));
    buf.add([0x0A]);

    if (data.receipt.discountTotal > 0) {
      buf.add(_encode(_padLine(
          'Discount', '-$currency ${_currencyFmt.format(data.receipt.discountTotal)}', paperWidth)));
      buf.add([0x0A]);
    }

    if (data.receipt.taxTotal > 0) {
      buf.add(_encode(_padLine(
          'Tax', '$currency ${_currencyFmt.format(data.receipt.taxTotal)}', paperWidth)));
      buf.add([0x0A]);
    }

    // Bold total
    buf.add([esc, 0x45, 0x01]); // ESC E 1 — bold on
    buf.add(_encode(_padLine(
        'TOTAL', '$currency ${_currencyFmt.format(data.receipt.total)}', paperWidth)));
    buf.add([0x0A]);
    buf.add([esc, 0x45, 0x00]); // ESC E 0 — bold off

    buf.add(_encode('-' * paperWidth));
    buf.add([0x0A]);

    // Payments
    for (final p in data.payments) {
      buf.add(_encode(_padLine(
          _paymentMethodLabel(p.method),
          '${p.currency} ${_currencyFmt.format(p.amount)}',
          paperWidth)));
      buf.add([0x0A]);
    }

    if (_calculateChange(data) > 0) {
      buf.add(_encode(_padLine(
          'Change', '$currency ${_currencyFmt.format(_calculateChange(data))}', paperWidth)));
      buf.add([0x0A]);
    }

    // Thank you
    buf.add([0x0A]);
    buf.add([esc, 0x61, 0x01]); // center
    buf.add(_encode('Thank you!'));
    buf.add([0x0A, 0x0A, 0x0A]); // feed 3 lines

    // Cut paper
    buf.add([gs, 0x56, 0x00]); // GS V 0 — full cut

    return buf.toBytes();
  }

  // ── Helpers ──

  static pw.Widget _pdfTotalRow(String label, double amount, String currency) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
        pw.Text('$currency ${_currencyFmt.format(amount)}',
            style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }

  static double _calculateChange(ReceiptData data) {
    final totalPaid =
        data.payments.fold(0.0, (sum, p) => sum + p.amount);
    return totalPaid - data.receipt.total;
  }

  static String _paymentMethodLabel(String method) {
    switch (method) {
      case 'cash':
        return 'Cash';
      case 'qr':
        return 'QR Payment';
      case 'card':
        return 'Card';
      default:
        return method;
    }
  }

  /// Pad a line so label is left-aligned, value is right-aligned.
  static String _padLine(String left, String right, int width) {
    final gap = width - left.length - right.length;
    if (gap <= 0) return '$left $right';
    return '$left${' ' * gap}$right';
  }

  /// Encode string to bytes (Latin-1 for ESC/POS).
  static Uint8List _encode(String text) {
    final bytes = <int>[];
    for (final c in text.codeUnits) {
      bytes.add(c > 255 ? 0x3F : c); // Replace non-Latin1 with '?'
    }
    return Uint8List.fromList(bytes);
  }
}
