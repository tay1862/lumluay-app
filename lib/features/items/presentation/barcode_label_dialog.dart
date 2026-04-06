import 'dart:typed_data';

import 'package:barcode/barcode.dart' as bc;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../i18n/strings.g.dart';

/// Dialog for generating barcode labels and printing them.
class BarcodeLabelDialog extends ConsumerStatefulWidget {
  final Item item;

  const BarcodeLabelDialog({super.key, required this.item});

  @override
  ConsumerState<BarcodeLabelDialog> createState() =>
      _BarcodeLabelDialogState();
}

class _BarcodeLabelDialogState extends ConsumerState<BarcodeLabelDialog> {
  int _quantity = 1;
  String _barcodeType = 'Code128';
  Uint8List? _preview;

  final _types = {
    'Code128': bc.Barcode.code128(),
    'EAN13': bc.Barcode.ean13(),
    'Code39': bc.Barcode.code39(),
    'UPC-A': bc.Barcode.upcA(),
    'QR Code': bc.Barcode.qrCode(),
  };

  String get _barcodeData =>
      widget.item.barcode?.isNotEmpty == true
          ? widget.item.barcode!
          : widget.item.sku?.isNotEmpty == true
              ? widget.item.sku!
              : widget.item.id.substring(0, 12);

  @override
  void initState() {
    super.initState();
    _generatePreview();
  }

  void _generatePreview() {
    try {
      final barcode = _types[_barcodeType]!;
      final svg = barcode.toSvg(_barcodeData, width: 200, height: 80);
      setState(() => _preview = Uint8List.fromList(svg.codeUnits));
    } catch (_) {
      setState(() => _preview = null);
    }
  }

  Future<void> _print() async {
    final item = widget.item;
    final barcode = _types[_barcodeType]!;
    final barcodeWidget = _barcodeType == 'QR Code'
        ? bc.Barcode.qrCode()
        : barcode;

    final doc = pw.Document();

    for (int i = 0; i < _quantity; i++) {
      doc.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(
            58 * PdfPageFormat.mm,
            40 * PdfPageFormat.mm,
            marginAll: 2 * PdfPageFormat.mm,
          ),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(item.name,
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.BarcodeWidget(
                barcode: barcodeWidget,
                data: _barcodeData,
                width: 48 * PdfPageFormat.mm,
                height: _barcodeType == 'QR Code' ? 20 * PdfPageFormat.mm : 16 * PdfPageFormat.mm,
                drawText: _barcodeType != 'QR Code',
                textStyle: const pw.TextStyle(fontSize: 8),
              ),
              pw.SizedBox(height: 2),
              pw.Text('₭${item.price.toStringAsFixed(0)}',
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (format) => doc.save(),
      name: 'label_${item.name}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Print Barcode Label'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item info
            Text(widget.item.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16)),
            Text('₭${widget.item.price.toStringAsFixed(0)}',
                style: TextStyle(color: theme.colorScheme.primary)),
            Text('Barcode: $_barcodeData',
                style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.mutedForeground)),
            const SizedBox(height: 16),

            // Barcode type selector
            const Text('Barcode Type',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _types.keys.map((type) => Button(
                    style: _barcodeType == type
                        ? const ButtonStyle.primary(
                            density: ButtonDensity.compact)
                        : const ButtonStyle.outline(
                            density: ButtonDensity.compact),
                    onPressed: () {
                      setState(() => _barcodeType = type);
                      _generatePreview();
                    },
                    child: Text(type),
                  )).toList(),
            ),
            const SizedBox(height: 16),

            // Preview
            if (_preview != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(widget.item.name,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    // Show barcode data text as preview since SVG rendering
                    // isn't available in shadcn widget set
                    Container(
                      height: 60,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.border),
                      ),
                      child: Center(
                        child: Text(_barcodeData,
                            style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'monospace',
                                color: theme.colorScheme.mutedForeground)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('₭${widget.item.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Quantity
            Row(
              children: [
                const Text('Labels to print:',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                IconButton.outline(
                  icon: const Icon(RadixIcons.minus, size: 14),
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                  size: ButtonSize.small,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('$_quantity',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                IconButton.outline(
                  icon: const Icon(RadixIcons.plus, size: 14),
                  onPressed: _quantity < 100
                      ? () => setState(() => _quantity++)
                      : null,
                  size: ButtonSize.small,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Button(
          style: const ButtonStyle.outline(),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.cancel),
        ),
        Button(
          style: const ButtonStyle.primary(),
          onPressed: _print,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(RadixIcons.download, size: 16),
              SizedBox(width: 6),
              Text('Print Labels'),
            ],
          ),
        ),
      ],
    );
  }
}
