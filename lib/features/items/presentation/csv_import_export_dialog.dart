import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'dart:convert';

import '../../../i18n/strings.g.dart';
import '../data/item_csv_service.dart';
import '../data/items_providers.dart';

class CsvImportExportDialog extends ConsumerStatefulWidget {
  final String storeId;

  const CsvImportExportDialog({super.key, required this.storeId});

  @override
  ConsumerState<CsvImportExportDialog> createState() =>
      _CsvImportExportDialogState();
}

class _CsvImportExportDialogState
    extends ConsumerState<CsvImportExportDialog> {
  bool _exporting = false;
  bool _importing = false;
  String _importStatus = '';
  final _csvController = TextEditingController();

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  Future<void> _exportCsv() async {
    setState(() => _exporting = true);
    try {
      final repo = ref.read(itemRepositoryProvider);
      final catRepo = ref.read(categoryRepositoryProvider);
      final items = await repo.getItems(widget.storeId);
      final categories = await catRepo.getCategories(widget.storeId);

      final csv = ItemCsvService.exportItems(items, categories);
      final bytes = utf8.encode(csv);

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'items_export.csv',
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _importCsv() async {
    final csvText = _csvController.text.trim();
    if (csvText.isEmpty) return;

    setState(() {
      _importing = true;
      _importStatus = '';
    });

    try {
      final parsed = ItemCsvService.parseItems(csvText);
      if (parsed.isEmpty) {
        setState(() => _importStatus = 'No valid items found in CSV');
        return;
      }

      final repo = ref.read(itemRepositoryProvider);
      final catRepo = ref.read(categoryRepositoryProvider);
      final existingCategories =
          await catRepo.getCategories(widget.storeId);
      final catMap = {for (final c in existingCategories) c.name: c.id};

      int created = 0;
      int errors = 0;

      for (final row in parsed) {
        String? categoryId;
        final catName = row['categoryName'] as String?;
        if (catName != null && catName.isNotEmpty) {
          categoryId = catMap[catName];
          if (categoryId == null) {
            // Create category
            final result =
                await catRepo.create(storeId: widget.storeId, name: catName);
            result.when(
              success: (cat) {
                categoryId = cat.id;
                catMap[catName] = cat.id;
              },
              failure: (_) {},
            );
          }
        }

        final result = await repo.create(
          storeId: widget.storeId,
          name: row['name'] as String,
          sku: row['sku'] as String?,
          barcode: row['barcode'] as String?,
          price: row['price'] as double,
          cost: row['cost'] as double,
          categoryId: categoryId,
          trackStock: row['trackStock'] as bool,
          soldByWeight: row['soldByWeight'] as bool,
        );
        result.when(
          success: (_) => created++,
          failure: (_) => errors++,
        );
      }

      setState(() =>
          _importStatus = 'Imported $created items${errors > 0 ? ' ($errors errors)' : ''}');
    } catch (e) {
      setState(() => _importStatus = 'Error: $e');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return AlertDialog(
      title: const Text('CSV Import / Export'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Export section
            const Text('Export Items',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text('Download all items as a CSV file.',
                style: TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            Button(
              style: const ButtonStyle.outline(),
              onPressed: _exporting ? null : _exportCsv,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(RadixIcons.download, size: 16),
                  const SizedBox(width: 6),
                  Text(_exporting ? 'Exporting...' : 'Export CSV'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: Theme.of(context).colorScheme.border),
            const SizedBox(height: 20),

            // Import section
            const Text('Import Items',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text(
                'Paste CSV content below. First row must be headers: Name, SKU, Barcode, Price, Cost, Category, Track Stock, Sold by Weight',
                style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: TextField(
                controller: _csvController,
                maxLines: null,
                expands: true,
                placeholder: const Text('Paste CSV content here...'),
              ),
            ),
            const SizedBox(height: 8),
            Button(
              style: const ButtonStyle.primary(),
              onPressed: _importing ? null : _importCsv,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(RadixIcons.upload, size: 16),
                  const SizedBox(width: 6),
                  Text(_importing ? 'Importing...' : 'Import CSV'),
                ],
              ),
            ),
            if (_importStatus.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_importStatus,
                  style: TextStyle(
                    color: _importStatus.contains('Error')
                        ? Colors.red
                        : Colors.green,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ],
        ),
      ),
      actions: [
        Button(
          style: const ButtonStyle.outline(),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.close),
        ),
      ],
    );
  }
}
