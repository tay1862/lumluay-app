import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../i18n/strings.g.dart';
import '../../settings/data/settings_providers.dart';
import '../../sales/data/tax_service.dart';
import '../data/items_providers.dart';
import 'barcode_label_dialog.dart';

class ItemFormDialog extends ConsumerStatefulWidget {
  final String storeId;
  final Item? existingItem;

  const ItemFormDialog({
    super.key,
    required this.storeId,
    this.existingItem,
  });

  @override
  ConsumerState<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends ConsumerState<ItemFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _priceController;
  late final TextEditingController _costController;
  String? _selectedCategoryId;
  bool _trackStock = false;
  bool _soldByWeight = false;
  bool _saving = false;
  Set<String> _selectedTaxRateIds = {};

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _skuController = TextEditingController(text: item?.sku ?? '');
    _barcodeController = TextEditingController(text: item?.barcode ?? '');
    _priceController =
        TextEditingController(text: item?.price.toStringAsFixed(0) ?? '0');
    _costController =
        TextEditingController(text: item?.cost.toStringAsFixed(0) ?? '0');
    _selectedCategoryId = item?.categoryId;
    _trackStock = item?.trackStock ?? false;
    _soldByWeight = item?.soldByWeight ?? false;
    if (_isEditing) {
      _loadTaxRates();
    }
  }

  Future<void> _loadTaxRates() async {
    final db = ref.read(databaseProvider);
    final taxService = TaxService(db);
    final ids = await taxService.getItemTaxRateIds(widget.existingItem!.id);
    if (mounted) setState(() => _selectedTaxRateIds = ids.toSet());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);

    final repo = ref.read(itemRepositoryProvider);
    final price = double.tryParse(_priceController.text) ?? 0;
    final cost = double.tryParse(_costController.text) ?? 0;
    final sku = _skuController.text.trim();
    final barcode = _barcodeController.text.trim();

    String? itemId;
    if (_isEditing) {
      itemId = widget.existingItem!.id;
      await repo.update(
        id: itemId,
        name: name,
        categoryId: _selectedCategoryId,
        sku: sku.isEmpty ? null : sku,
        barcode: barcode.isEmpty ? null : barcode,
        price: price,
        cost: cost,
        trackStock: _trackStock,
        soldByWeight: _soldByWeight,
      );
    } else {
      final result = await repo.create(
        storeId: widget.storeId,
        name: name,
        categoryId: _selectedCategoryId,
        sku: sku.isEmpty ? null : sku,
        barcode: barcode.isEmpty ? null : barcode,
        price: price,
        cost: cost,
        trackStock: _trackStock,
        soldByWeight: _soldByWeight,
      );
      result.when(
        success: (item) => itemId = item.id,
        failure: (_) {},
      );
    }

    // Save tax rate assignments
    if (itemId != null) {
      final db = ref.read(databaseProvider);
      final taxService = TaxService(db);
      final existingIds = await taxService.getItemTaxRateIds(itemId!);
      for (final oldId in existingIds) {
        if (!_selectedTaxRateIds.contains(oldId)) {
          await taxService.removeTaxFromItem(itemId!, oldId);
        }
      }
      for (final newId in _selectedTaxRateIds) {
        if (!existingIds.contains(newId)) {
          await taxService.assignTaxToItem(itemId!, newId);
        }
      }
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    if (!_isEditing) return;
    setState(() => _saving = true);
    final repo = ref.read(itemRepositoryProvider);
    await repo.delete(widget.existingItem!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return AlertDialog(
      title: Text(_isEditing ? t.items.editItem : t.items.addItem),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              _label(t.items.itemName),
              TextField(
                controller: _nameController,
                placeholder: Text(t.items.itemName),
              ),
              const SizedBox(height: 12),

              // Category picker (chip buttons)
              _label(t.items.categories),
              categoriesAsync.when(
                data: (categories) {
                  return Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Button(
                        style: _selectedCategoryId == null
                            ? const ButtonStyle.primary(density: ButtonDensity.compact)
                            : const ButtonStyle.outline(density: ButtonDensity.compact),
                        onPressed: () => setState(() => _selectedCategoryId = null),
                        child: const Text('—'),
                      ),
                      ...categories.map((cat) => Button(
                            style: _selectedCategoryId == cat.id
                                ? const ButtonStyle.primary(density: ButtonDensity.compact)
                                : const ButtonStyle.outline(density: ButtonDensity.compact),
                            onPressed: () => setState(() => _selectedCategoryId = cat.id),
                            child: Text(cat.name),
                          )),
                    ],
                  );
                },
                loading: () => const SizedBox(height: 36),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: 12),

              // Price and Cost
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label(t.common.price),
                        TextField(
                          controller: _priceController,
                          placeholder: const Text('0'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label(t.items.cost),
                        TextField(
                          controller: _costController,
                          placeholder: const Text('0'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // SKU and Barcode
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label(t.items.sku),
                        TextField(
                          controller: _skuController,
                          placeholder: Text(t.items.sku),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label(t.items.barcode),
                        TextField(
                          controller: _barcodeController,
                          placeholder: Text(t.items.barcode),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Toggles
              Row(
                children: [
                  Checkbox(
                    state: _trackStock ? CheckboxState.checked : CheckboxState.unchecked,
                    onChanged: (v) =>
                        setState(() => _trackStock = v == CheckboxState.checked),
                    trailing: Text(t.items.trackStock),
                  ),
                  const SizedBox(width: 24),
                  Checkbox(
                    state: _soldByWeight ? CheckboxState.checked : CheckboxState.unchecked,
                    onChanged: (v) =>
                        setState(() => _soldByWeight = v == CheckboxState.checked),
                    trailing: Text(t.items.soldByWeight),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tax Rates
              _label(t.settings.taxes),
              _buildTaxRateSelector(),
            ],
          ),
        ),
      ),
      actions: [
        if (_isEditing)
          Button(
            style: const ButtonStyle.destructive(),
            onPressed: _saving ? null : _delete,
            child: Text(t.common.delete),
          ),
        if (_isEditing)
          Button(
            style: const ButtonStyle.outline(),
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (_) => BarcodeLabelDialog(item: widget.existingItem!),
              );
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(RadixIcons.reader, size: 16),
                SizedBox(width: 6),
                Text('Print Label'),
              ],
            ),
          ),
        const Spacer(),
        Button(
          style: const ButtonStyle.outline(),
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(t.common.cancel),
        ),
        const SizedBox(width: 8),
        Button(
          style: const ButtonStyle.primary(),
          onPressed: _saving ? null : _save,
          child: Text(t.common.save),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTaxRateSelector() {
    final taxRatesAsync = ref.watch(taxRatesStreamProvider(widget.storeId));
    return taxRatesAsync.when(
      data: (taxRates) {
        if (taxRates.isEmpty) {
          return Text('No tax rates configured',
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.mutedForeground));
        }
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: taxRates.map((rate) {
            final selected = _selectedTaxRateIds.contains(rate.id);
            return Button(
              style: selected
                  ? const ButtonStyle.primary(density: ButtonDensity.compact)
                  : const ButtonStyle.outline(density: ButtonDensity.compact),
              onPressed: () {
                setState(() {
                  if (selected) {
                    _selectedTaxRateIds.remove(rate.id);
                  } else {
                    _selectedTaxRateIds.add(rate.id);
                  }
                });
              },
              child: Text('${rate.name} (${rate.rate}%)'),
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox(height: 24),
      error: (e, _) => Text('$e'),
    );
  }
}
