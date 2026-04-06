import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../i18n/strings.g.dart';
import '../../items/data/items_providers.dart';
import '../data/inventory_providers.dart';

class PurchaseOrderDialog extends ConsumerStatefulWidget {
  final String storeId;

  const PurchaseOrderDialog({super.key, required this.storeId});

  @override
  ConsumerState<PurchaseOrderDialog> createState() =>
      _PurchaseOrderDialogState();
}

class _PurchaseOrderDialogState extends ConsumerState<PurchaseOrderDialog> {
  String? _selectedSupplierId;
  final List<_POLineItem> _lineItems = [];
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final suppliersAsync = ref.watch(suppliersProvider(widget.storeId));

    final total = _lineItems.fold<double>(
        0, (sum, item) => sum + item.quantity * item.cost);

    return AlertDialog(
      title: Text(t.inventory.createPO),
      content: SizedBox(
        width: 550,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Supplier selector
            suppliersAsync.when(
              data: (suppliers) {
                return Select<String?>(
                  value: _selectedSupplierId,
                  onChanged: (v) => setState(() => _selectedSupplierId = v),
                  placeholder: Text(t.inventory.selectSupplier),
                  itemBuilder: (context, item) => Text(
                    suppliers.firstWhere((s) => s.id == item).name,
                  ),
                  popupConstraints: const BoxConstraints(maxHeight: 200),
                  popup: (_) => SelectPopup(
                    items: SelectItemList(
                      children: [
                        for (final s in suppliers)
                          SelectItemButton(value: s.id, child: Text(s.name)),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),

            // Add item button
            Button(
              style: const ButtonStyle.outline(),
              onPressed: () => _addItem(context),
              leading: const Icon(RadixIcons.plus),
              child: Text(t.inventory.addItems),
            ),
            const SizedBox(height: 12),

            // Line items
            Expanded(
              child: _lineItems.isEmpty
                  ? Center(
                      child: Text(t.common.noData,
                          style: TextStyle(
                              color: theme.colorScheme.mutedForeground)),
                    )
                  : ListView.builder(
                      itemCount: _lineItems.length,
                      itemBuilder: (context, index) {
                        final item = _lineItems[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(item.itemName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                              ),
                              SizedBox(
                                width: 70,
                                child: TextField(
                                  initialValue:
                                      item.quantity.toStringAsFixed(0),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) {
                                    final qty = double.tryParse(v) ?? 0;
                                    setState(
                                        () => _lineItems[index].quantity = qty);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 90,
                                child: TextField(
                                  initialValue: item.cost.toStringAsFixed(0),
                                  keyboardType: TextInputType.number,
                                  placeholder: Text(t.inventory.unitCost),
                                  onChanged: (v) {
                                    final cost = double.tryParse(v) ?? 0;
                                    setState(
                                        () => _lineItems[index].cost = cost);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                (item.quantity * item.cost)
                                    .toStringAsFixed(0),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              IconButton.ghost(
                                icon: const Icon(RadixIcons.cross2, size: 14),
                                onPressed: () => setState(
                                    () => _lineItems.removeAt(index)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Total
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${t.common.total}: ',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(total.toStringAsFixed(0),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
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
          onPressed: _lineItems.isEmpty || _saving ? null : _save,
          child: Text(t.common.save),
        ),
      ],
    );
  }

  void _addItem(BuildContext context) async {
    final itemsAsync = ref.read(itemsStreamProvider(null));
    final allItems = itemsAsync.valueOrNull ?? [];

    if (allItems.isEmpty) return;

    final selected = await showDialog<Item>(
      context: context,
      builder: (_) => _ItemPickerDialog(items: allItems),
    );

    if (selected != null) {
      setState(() {
        _lineItems.add(_POLineItem(
          itemId: selected.id,
          itemName: selected.name,
          quantity: 1,
          cost: selected.cost,
        ));
      });
    }
  }

  void _save() async {
    setState(() => _saving = true);
    final t = Translations.of(context);
    final repo = ref.read(purchaseOrderRepositoryProvider);

    final items = _lineItems
        .map((l) => (itemId: l.itemId, quantity: l.quantity, cost: l.cost))
        .toList();

    final result = await repo.createPurchaseOrder(
      storeId: widget.storeId,
      supplierId: _selectedSupplierId,
      items: items,
    );

    if (!mounted) return;
    result.when(
      success: (_) {
        showToast(
          context: context,
          builder: (_, _) => SurfaceCard(
            child: Basic(title: Text(t.inventory.poCreated)),
          ),
          location: ToastLocation.bottomRight,
          showDuration: const Duration(seconds: 2),
        );
        Navigator.of(context).pop();
      },
      failure: (e) {
        showToast(
          context: context,
          builder: (_, _) =>
              SurfaceCard(child: Basic(title: Text(e.message))),
          location: ToastLocation.bottomRight,
          showDuration: const Duration(seconds: 3),
        );
        setState(() => _saving = false);
      },
    );
  }
}

class _POLineItem {
  final String itemId;
  final String itemName;
  double quantity;
  double cost;

  _POLineItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.cost,
  });
}

// ── Item Picker Dialog ──

class _ItemPickerDialog extends StatefulWidget {
  final List<Item> items;
  const _ItemPickerDialog({required this.items});

  @override
  State<_ItemPickerDialog> createState() => _ItemPickerDialogState();
}

class _ItemPickerDialogState extends State<_ItemPickerDialog> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final filtered = widget.items
        .where(
            (i) => i.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return AlertDialog(
      title: Text(t.inventory.selectItems),
      content: SizedBox(
        width: 400,
        height: 400,
        child: Column(
          children: [
            TextField(
              placeholder: Text(t.common.search),
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return GestureDetector(
                    onTap: () => Navigator.of(context).pop(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name),
                                if (item.sku != null)
                                  Text(item.sku!,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.gray)),
                              ],
                            ),
                          ),
                          Text(item.cost.toStringAsFixed(0)),
                        ],
                      ),
                    ),
                  );
                },
              ),
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
      ],
    );
  }
}
