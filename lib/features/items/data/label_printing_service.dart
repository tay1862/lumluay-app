import 'dart:typed_data';

import 'package:barcode/barcode.dart' as bc;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/database/app_database.dart';

/// Label template types
enum LabelTemplate { priceTag, shelfLabel, barcodeOnly, custom }

/// Generates various label layouts for items.
class LabelPrintingService {
  /// Price tag: name + price + barcode (small tag format)
  static Future<Uint8List> generatePriceTag({
    required Item item,
    int quantity = 1,
    String currencySymbol = '₭',
  }) async {
    final doc = pw.Document();
    final barcodeData = item.barcode ?? item.sku ?? item.id.substring(0, 12);

    for (var i = 0; i < quantity; i++) {
      doc.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(
              5.0 * PdfPageFormat.cm, 3.0 * PdfPageFormat.cm,
              marginAll: 4),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                item.name,
                style: pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold),
                maxLines: 2,
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                '$currencySymbol${item.price.toStringAsFixed(item.price == item.price.roundToDouble() ? 0 : 2)}',
                style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.BarcodeWidget(
                barcode: bc.Barcode.code128(),
                data: barcodeData,
                width: 4.0 * PdfPageFormat.cm,
                height: 0.6 * PdfPageFormat.cm,
                textStyle: const pw.TextStyle(fontSize: 6),
              ),
            ],
          ),
        ),
      );
    }
    return doc.save();
  }

  /// Shelf label: name + price + SKU (wider format for shelves)
  static Future<Uint8List> generateShelfLabel({
    required Item item,
    int quantity = 1,
    String currencySymbol = '₭',
  }) async {
    final doc = pw.Document();

    for (var i = 0; i < quantity; i++) {
      doc.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(
              7.0 * PdfPageFormat.cm, 3.0 * PdfPageFormat.cm,
              marginAll: 6),
          build: (context) => pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Left: name + SKU
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      item.name,
                      style: pw.TextStyle(
                          fontSize: 11, fontWeight: pw.FontWeight.bold),
                      maxLines: 2,
                    ),
                    if (item.sku != null && item.sku!.isNotEmpty)
                      pw.Text(
                        'SKU: ${item.sku}',
                        style: const pw.TextStyle(fontSize: 7),
                      ),
                  ],
                ),
              ),
              pw.SizedBox(width: 8),
              // Right: price
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1.5),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  '$currencySymbol${item.price.toStringAsFixed(item.price == item.price.roundToDouble() ? 0 : 2)}',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return doc.save();
  }

  /// Barcode-only label (compact)
  static Future<Uint8List> generateBarcodeOnly({
    required Item item,
    int quantity = 1,
  }) async {
    final doc = pw.Document();
    final barcodeData = item.barcode ?? item.sku ?? item.id.substring(0, 12);

    for (var i = 0; i < quantity; i++) {
      doc.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(
              5.0 * PdfPageFormat.cm, 1.5 * PdfPageFormat.cm,
              marginAll: 2),
          build: (context) => pw.Center(
            child: pw.BarcodeWidget(
              barcode: bc.Barcode.code128(),
              data: barcodeData,
              width: 4.5 * PdfPageFormat.cm,
              height: 1.0 * PdfPageFormat.cm,
              textStyle: const pw.TextStyle(fontSize: 6),
            ),
          ),
        ),
      );
    }
    return doc.save();
  }

  /// Custom label with user-defined fields
  static Future<Uint8List> generateCustomLabel({
    required Item item,
    int quantity = 1,
    String currencySymbol = '₭',
    bool showName = true,
    bool showPrice = true,
    bool showBarcode = true,
    bool showSku = true,
    bool showCategory = false,
    String? categoryName,
  }) async {
    final doc = pw.Document();
    final barcodeData = item.barcode ?? item.sku ?? item.id.substring(0, 12);

    for (var i = 0; i < quantity; i++) {
      doc.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(
              5.0 * PdfPageFormat.cm, 3.5 * PdfPageFormat.cm,
              marginAll: 4),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              if (showName)
                pw.Text(
                  item.name,
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold),
                  maxLines: 2,
                  textAlign: pw.TextAlign.center,
                ),
              if (showCategory && categoryName != null) ...[
                pw.SizedBox(height: 2),
                pw.Text(categoryName,
                    style: const pw.TextStyle(fontSize: 7)),
              ],
              if (showSku && item.sku != null && item.sku!.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text('SKU: ${item.sku}',
                    style: const pw.TextStyle(fontSize: 7)),
              ],
              if (showPrice) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  '$currencySymbol${item.price.toStringAsFixed(item.price == item.price.roundToDouble() ? 0 : 2)}',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ],
              if (showBarcode) ...[
                pw.SizedBox(height: 4),
                pw.BarcodeWidget(
                  barcode: bc.Barcode.code128(),
                  data: barcodeData,
                  width: 4.0 * PdfPageFormat.cm,
                  height: 0.6 * PdfPageFormat.cm,
                  textStyle: const pw.TextStyle(fontSize: 6),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return doc.save();
  }

  /// Print labels for a batch of items using the given template.
  static Future<void> printBatch({
    required List<Item> items,
    required LabelTemplate template,
    int quantityEach = 1,
    String currencySymbol = '₭',
  }) async {
    for (final item in items) {
      final bytes = switch (template) {
        LabelTemplate.priceTag => await generatePriceTag(
            item: item,
            quantity: quantityEach,
            currencySymbol: currencySymbol),
        LabelTemplate.shelfLabel => await generateShelfLabel(
            item: item,
            quantity: quantityEach,
            currencySymbol: currencySymbol),
        LabelTemplate.barcodeOnly =>
          await generateBarcodeOnly(item: item, quantity: quantityEach),
        LabelTemplate.custom => await generateCustomLabel(
            item: item,
            quantity: quantityEach,
            currencySymbol: currencySymbol),
      };

      await Printing.layoutPdf(
        onLayout: (_) => bytes,
        name: 'Labels - ${item.name}',
      );
    }
  }
}
