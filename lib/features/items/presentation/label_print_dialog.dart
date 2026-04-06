import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../data/label_printing_service.dart';

/// Dialog for batch printing labels with template selection.
class LabelPrintDialog extends ConsumerStatefulWidget {
  final List<Item> items;

  const LabelPrintDialog({super.key, required this.items});

  @override
  ConsumerState<LabelPrintDialog> createState() => _LabelPrintDialogState();
}

class _LabelPrintDialogState extends ConsumerState<LabelPrintDialog> {
  LabelTemplate _template = LabelTemplate.priceTag;
  int _quantity = 1;
  bool _printing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Print Labels'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.items.length} item(s) selected',
                style: TextStyle(
                    color: theme.colorScheme.mutedForeground, fontSize: 13)),
            const SizedBox(height: 16),

            // Template selection
            const Text('Template',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _templateChip(LabelTemplate.priceTag, 'Price Tag',
                    'Name + price + barcode'),
                _templateChip(LabelTemplate.shelfLabel, 'Shelf Label',
                    'Name + SKU + price'),
                _templateChip(LabelTemplate.barcodeOnly, 'Barcode Only',
                    'Compact barcode'),
                _templateChip(
                    LabelTemplate.custom, 'Custom', 'All fields'),
              ],
            ),
            const SizedBox(height: 16),

            // Quantity per item
            Row(
              children: [
                const Text('Quantity per item',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const Spacer(),
                IconButton.outline(
                  icon: const Icon(RadixIcons.minus, size: 14),
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                  variance: ButtonVariance.outline,
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
                  variance: ButtonVariance.outline,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Total labels: ${widget.items.length * _quantity}',
              style: TextStyle(
                  fontSize: 12, color: theme.colorScheme.mutedForeground),
            ),
          ],
        ),
      ),
      actions: [
        Button(
          style: const ButtonStyle.ghost(),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Button(
          style: const ButtonStyle.primary(),
          onPressed: _printing ? null : _print,
          child: _printing
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text('Printing...'),
                  ],
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(RadixIcons.download, size: 14),
                    SizedBox(width: 6),
                    Text('Print'),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _templateChip(
      LabelTemplate template, String label, String subtitle) {
    final isSelected = _template == template;
    return GestureDetector(
      onTap: () => setState(() => _template = template),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.mutedForeground)),
          ],
        ),
      ),
    );
  }

  Future<void> _print() async {
    setState(() => _printing = true);
    try {
      for (final item in widget.items) {
        final bytes = switch (_template) {
          LabelTemplate.priceTag =>
            await LabelPrintingService.generatePriceTag(
                item: item, quantity: _quantity),
          LabelTemplate.shelfLabel =>
            await LabelPrintingService.generateShelfLabel(
                item: item, quantity: _quantity),
          LabelTemplate.barcodeOnly =>
            await LabelPrintingService.generateBarcodeOnly(
                item: item, quantity: _quantity),
          LabelTemplate.custom =>
            await LabelPrintingService.generateCustomLabel(
                item: item, quantity: _quantity),
        };
        await Printing.layoutPdf(
          onLayout: (_) => bytes,
          name: 'Label - ${item.name}',
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }
}
