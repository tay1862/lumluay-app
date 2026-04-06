import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/database/app_database.dart';

/// Kitchen ticket data for printing.
class KitchenTicketData {
  final String ticketName;
  final String station;
  final String? tableName;
  final List<OpenTicketItem> items;
  final DateTime createdAt;

  const KitchenTicketData({
    required this.ticketName,
    required this.station,
    this.tableName,
    required this.items,
    required this.createdAt,
  });
}

/// Generates and prints kitchen tickets routed by category → station.
class KitchenPrinterService {
  /// Build a kitchen ticket PDF (large font, clear layout for kitchen).
  static Future<Uint8List> generateKitchenTicket(
      KitchenTicketData data) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(8),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Station header
            pw.Center(
              child: pw.Text(
                '[ ${data.station.toUpperCase()} ]',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Divider(),

            // Ticket info
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(data.ticketName,
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                if (data.tableName != null)
                  pw.Text(data.tableName!,
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              '${data.createdAt.hour.toString().padLeft(2, '0')}:${data.createdAt.minute.toString().padLeft(2, '0')}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Divider(),

            // Items — large font with modifiers and notes
            ...data.items.map((item) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'x${item.quantity.toInt()}  ${item.name}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (item.modifiers != '[]' && item.modifiers.isNotEmpty)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 20),
                          child: pw.Text(
                            _formatModifiers(item.modifiers),
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ),
                      if (item.notes != null && item.notes!.isNotEmpty)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 20),
                          child: pw.Text(
                            '** ${item.notes} **',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              fontStyle: pw.FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                )),

            pw.Divider(),
            pw.Center(
              child: pw.Text(
                '${data.items.length} item(s)',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  /// Print a kitchen ticket.
  static Future<void> printKitchenTicket(KitchenTicketData data) async {
    final bytes = await generateKitchenTicket(data);
    await Printing.layoutPdf(
      onLayout: (_) => bytes,
      name: 'Kitchen - ${data.station} - ${data.ticketName}',
    );
  }

  /// Group ticket items by station and print separate tickets per station.
  static Future<void> printByStation({
    required String ticketName,
    String? tableName,
    required List<OpenTicketItem> items,
  }) async {
    final byStation = <String, List<OpenTicketItem>>{};
    for (final item in items) {
      final station = item.kdsStation ?? 'kitchen';
      byStation.putIfAbsent(station, () => []).add(item);
    }
    for (final entry in byStation.entries) {
      await printKitchenTicket(KitchenTicketData(
        ticketName: ticketName,
        station: entry.key,
        tableName: tableName,
        items: entry.value,
        createdAt: DateTime.now(),
      ));
    }
  }

  static String _formatModifiers(String modifiersJson) {
    try {
      // Simple parse: extract names
      final regex = RegExp(r'"name"\s*:\s*"([^"]*)"');
      final matches = regex.allMatches(modifiersJson);
      return matches.map((m) => '+ ${m.group(1)}').join('\n');
    } catch (_) {
      return '';
    }
  }
}
