import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../i18n/strings.g.dart';
import '../../items/data/items_providers.dart';
import '../data/inventory_providers.dart';

class TransferScreen extends ConsumerWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final auth = ref.watch(authProvider);
    final storeId = auth.currentStoreId ?? '';

    final transfersAsync = ref.watch(transferOrdersProvider(storeId));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(t.inventory.transfers,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              Button(
                style: const ButtonStyle.primary(),
                onPressed: () => _showCreateTransfer(context, ref, storeId),
                leading: const Icon(RadixIcons.plus),
                child: Text(t.inventory.createTransfer),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: transfersAsync.when(
              data: (transfers) {
                if (transfers.isEmpty) {
                  return Center(
                    child: Text(t.inventory.noTransfers,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .mutedForeground)),
                  );
                }
                return ListView.separated(
                  itemCount: transfers.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final tr = transfers[index];
                    return _TransferRow(transfer: tr, currentStoreId: storeId);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateTransfer(
      BuildContext context, WidgetRef ref, String storeId) {
    showDialog(
      context: context,
      builder: (_) => CreateTransferDialog(storeId: storeId),
    );
  }
}

class _TransferRow extends ConsumerWidget {
  final TransferOrder transfer;
  final String currentStoreId;

  const _TransferRow({required this.transfer, required this.currentStoreId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    final statusLabel = switch (transfer.status) {
      'pending' => t.inventory.pending,
      'in_transit' => t.inventory.inTransit,
      'completed' => t.receipts.completed,
      _ => transfer.status,
    };

    final statusColor = switch (transfer.status) {
      'pending' => theme.colorScheme.mutedForeground,
      'in_transit' => Colors.orange,
      'completed' => Colors.green,
      _ => Colors.gray,
    };

    final isInbound = transfer.toStoreId == currentStoreId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          Icon(
            isInbound ? RadixIcons.arrowDown : RadixIcons.arrowUp,
            size: 18,
            color: isInbound ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transfer.id.substring(0, 8).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  isInbound
                      ? '${t.inventory.fromStore}: ${transfer.fromStoreId.substring(0, 8)}'
                      : '${t.inventory.toStore}: ${transfer.toStoreId.substring(0, 8)}',
                  style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.mutedForeground),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(statusLabel,
                style: TextStyle(fontSize: 12, color: statusColor)),
          ),
          if (transfer.status == 'in_transit' && isInbound) ...[
            const SizedBox(width: 8),
            Button(
              style: const ButtonStyle.primary(),
              onPressed: () => _completeTransfer(context, ref),
              child: Text(t.common.done),
            ),
          ],
        ],
      ),
    );
  }

  void _completeTransfer(BuildContext context, WidgetRef ref) async {
    final t = Translations.of(context);
    final repo = ref.read(transferRepositoryProvider);
    final auth = ref.read(authProvider);

    final result = await repo.completeTransfer(
      transferId: transfer.id,
      employeeId: auth.currentEmployee?.id,
    );

    if (!context.mounted) return;
    result.when(
      success: (_) {
        showToast(
          context: context,
          builder: (_, _) => SurfaceCard(
            child: Basic(title: Text(t.inventory.transferCompleted)),
          ),
          location: ToastLocation.bottomRight,
          showDuration: const Duration(seconds: 2),
        );
      },
      failure: (e) {
        showToast(
          context: context,
          builder: (_, _) =>
              SurfaceCard(child: Basic(title: Text(e.message))),
          location: ToastLocation.bottomRight,
          showDuration: const Duration(seconds: 3),
        );
      },
    );
  }
}

// ── Create Transfer Dialog ──

class CreateTransferDialog extends ConsumerStatefulWidget {
  final String storeId;

  const CreateTransferDialog({super.key, required this.storeId});

  @override
  ConsumerState<CreateTransferDialog> createState() =>
      _CreateTransferDialogState();
}

class _CreateTransferDialogState extends ConsumerState<CreateTransferDialog> {
  final _toStoreIdCtrl = TextEditingController();
  final List<_TransferLine> _lineItems = [];
  bool _saving = false;

  @override
  void dispose() {
    _toStoreIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(t.inventory.createTransfer),
      content: SizedBox(
        width: 500,
        height: 450,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _toStoreIdCtrl,
              placeholder: Text(t.inventory.toStore),
            ),
            const SizedBox(height: 16),
            Button(
              style: const ButtonStyle.outline(),
              onPressed: () => _addItem(context),
              leading: const Icon(RadixIcons.plus),
              child: Text(t.inventory.selectItems),
            ),
            const SizedBox(height: 12),
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
                                child: Text(item.itemName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                              ),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  initialValue:
                                      item.quantity.toStringAsFixed(0),
                                  keyboardType: TextInputType.number,
                                  placeholder: Text(t.common.quantity),
                                  onChanged: (v) {
                                    final qty = double.tryParse(v) ?? 0;
                                    setState(
                                        () => _lineItems[index].quantity = qty);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.ghost(
                                icon:
                                    const Icon(RadixIcons.cross2, size: 14),
                                onPressed: () => setState(
                                    () => _lineItems.removeAt(index)),
                              ),
                            ],
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
        Button(
          style: const ButtonStyle.primary(),
          onPressed: _lineItems.isEmpty ||
                  _toStoreIdCtrl.text.trim().isEmpty ||
                  _saving
              ? null
              : _save,
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
      builder: (_) => _TransferItemPicker(items: allItems),
    );

    if (selected != null) {
      setState(() {
        _lineItems.add(_TransferLine(
          itemId: selected.id,
          itemName: selected.name,
          quantity: 1,
        ));
      });
    }
  }

  void _save() async {
    setState(() => _saving = true);
    final t = Translations.of(context);
    final repo = ref.read(transferRepositoryProvider);
    final auth = ref.read(authProvider);

    final items = _lineItems
        .map((l) => (itemId: l.itemId, quantity: l.quantity))
        .toList();

    final result = await repo.createTransfer(
      fromStoreId: widget.storeId,
      toStoreId: _toStoreIdCtrl.text.trim(),
      items: items,
      employeeId: auth.currentEmployee?.id,
    );

    if (!mounted) return;
    result.when(
      success: (_) {
        showToast(
          context: context,
          builder: (_, _) => SurfaceCard(
            child: Basic(title: Text(t.inventory.transferCreated)),
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

class _TransferLine {
  final String itemId;
  final String itemName;
  double quantity;

  _TransferLine({
    required this.itemId,
    required this.itemName,
    required this.quantity,
  });
}

class _TransferItemPicker extends StatefulWidget {
  final List<Item> items;
  const _TransferItemPicker({required this.items});

  @override
  State<_TransferItemPicker> createState() => _TransferItemPickerState();
}

class _TransferItemPickerState extends State<_TransferItemPicker> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final filtered = widget.items
        .where((i) => i.name.toLowerCase().contains(_search.toLowerCase()))
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
                      child: Text(item.name),
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
