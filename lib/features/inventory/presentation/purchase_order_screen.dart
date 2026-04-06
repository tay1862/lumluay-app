import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../i18n/strings.g.dart';
import '../data/inventory_providers.dart';
import '../data/purchase_order_repository.dart';
import 'supplier_dialog.dart';
import 'purchase_order_dialog.dart';

class PurchaseOrderScreen extends ConsumerWidget {
  const PurchaseOrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final auth = ref.watch(authProvider);
    final storeId = auth.currentStoreId ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(t.inventory.purchaseOrders,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              Button(
                style: const ButtonStyle.outline(),
                onPressed: () => _showSupplierDialog(context, ref, storeId),
                leading: const Icon(RadixIcons.person),
                child: Text(t.inventory.suppliers),
              ),
              const SizedBox(width: 8),
              Button(
                style: const ButtonStyle.primary(),
                onPressed: () => _showCreatePO(context, ref, storeId),
                leading: const Icon(RadixIcons.plus),
                child: Text(t.inventory.createPO),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _POList(storeId: storeId)),
        ],
      ),
    );
  }

  void _showSupplierDialog(
      BuildContext context, WidgetRef ref, String storeId) {
    showDialog(
      context: context,
      builder: (_) => SupplierListDialog(storeId: storeId),
    );
  }

  void _showCreatePO(BuildContext context, WidgetRef ref, String storeId) {
    showDialog(
      context: context,
      builder: (_) => PurchaseOrderDialog(storeId: storeId),
    );
  }
}

class _POList extends ConsumerWidget {
  final String storeId;
  const _POList({required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final posAsync = ref.watch(purchaseOrdersProvider(storeId));

    return posAsync.when(
      data: (pos) {
        if (pos.isEmpty) {
          return Center(
            child: Text(t.inventory.noPurchaseOrders,
                style: TextStyle(color: theme.colorScheme.mutedForeground)),
          );
        }
        return ListView.separated(
          itemCount: pos.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, index) =>
              _PORow(po: pos[index], storeId: storeId),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

class _PORow extends ConsumerWidget {
  final PurchaseOrderWithSupplier po;
  final String storeId;

  const _PORow({required this.po, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    final statusLabel = switch (po.po.status) {
      'draft' => t.inventory.draft,
      'ordered' => t.inventory.ordered,
      'partially_received' => t.inventory.partiallyReceived,
      'received' => t.inventory.receivedStatus,
      _ => po.po.status,
    };

    final statusColor = switch (po.po.status) {
      'draft' => theme.colorScheme.mutedForeground,
      'ordered' => Colors.blue,
      'received' => Colors.green,
      _ => Colors.orange,
    };

    return GestureDetector(
      onTap: () => _showPODetail(context, ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: statusColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${t.inventory.poNumber}${po.po.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(po.supplierName ?? '-',
                      style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.mutedForeground)),
                ],
              ),
            ),
            Text('${po.itemCount} ${t.nav.items}',
                style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.mutedForeground)),
            const SizedBox(width: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(statusLabel,
                  style: TextStyle(fontSize: 12, color: statusColor)),
            ),
            const SizedBox(width: 16),
            Text('${po.po.currency} ${po.po.total.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            if (po.po.status == 'draft' || po.po.status == 'ordered') ...[
              const SizedBox(width: 8),
              if (po.po.status == 'ordered')
                IconButton.ghost(
                  icon: const Icon(RadixIcons.download, size: 16),
                  onPressed: () => _showReceive(context, ref),
                ),
              if (po.po.status == 'draft')
                IconButton.ghost(
                  icon: const Icon(RadixIcons.trash, size: 16),
                  onPressed: () => _deletePO(context, ref),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPODetail(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => PODetailDialog(poId: po.po.id, storeId: storeId),
    );
  }

  void _showReceive(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) =>
          ReceiveStockDialog(poId: po.po.id, storeId: storeId),
    );
  }

  void _deletePO(BuildContext context, WidgetRef ref) async {
    final t = Translations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.common.confirm),
        content: Text(t.common.confirm),
        actions: [
          Button(
            style: const ButtonStyle.outline(),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.common.cancel),
          ),
          Button(
            style: const ButtonStyle.destructive(),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.common.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final repo = ref.read(purchaseOrderRepositoryProvider);
      await repo.deletePurchaseOrder(po.po.id);
    }
  }
}

// ── PO Detail Dialog ──

class PODetailDialog extends ConsumerWidget {
  final String poId;
  final String storeId;

  const PODetailDialog(
      {super.key, required this.poId, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final itemsAsync = ref.watch(poItemsProvider(poId));

    return AlertDialog(
      title: Text(
          '${t.inventory.poNumber}${poId.substring(0, 8).toUpperCase()}'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: itemsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return Center(child: Text(t.common.noData));
            }
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.itemName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            if (item.sku != null)
                              Text(item.sku!,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: theme
                                          .colorScheme.mutedForeground)),
                          ],
                        ),
                      ),
                      Text(
                          '×${item.poItem.quantity.toStringAsFixed(0)}'),
                      const SizedBox(width: 16),
                      Text(item.poItem.cost.toStringAsFixed(0),
                          style: const TextStyle(
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              },
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
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

// ── Receive Stock Dialog ──

class ReceiveStockDialog extends ConsumerStatefulWidget {
  final String poId;
  final String storeId;

  const ReceiveStockDialog({
    super.key,
    required this.poId,
    required this.storeId,
  });

  @override
  ConsumerState<ReceiveStockDialog> createState() =>
      _ReceiveStockDialogState();
}

class _ReceiveStockDialogState extends ConsumerState<ReceiveStockDialog> {
  final Map<String, TextEditingController> _controllers = {};
  bool _saving = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final itemsAsync = ref.watch(poItemsProvider(widget.poId));

    return AlertDialog(
      title: Text(t.inventory.receiveStock),
      content: SizedBox(
        width: 500,
        height: 400,
        child: itemsAsync.when(
          data: (items) {
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                _controllers.putIfAbsent(
                  item.poItem.itemId,
                  () => TextEditingController(
                      text:
                          item.poItem.quantity.toStringAsFixed(0)),
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(item.itemName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            Text(
                              '${t.inventory.ordered}: ${item.poItem.quantity.toStringAsFixed(0)}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: theme
                                      .colorScheme.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller:
                              _controllers[item.poItem.itemId],
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
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
          onPressed: _saving ? null : _receiveStock,
          child: Text(t.inventory.receiveStock),
        ),
      ],
    );
  }

  void _receiveStock() async {
    final t = Translations.of(context);
    setState(() => _saving = true);
    final repo = ref.read(purchaseOrderRepositoryProvider);
    final auth = ref.read(authProvider);

    final receivedItems = _controllers.entries.map((e) {
      final qty = double.tryParse(e.value.text) ?? 0;
      return (itemId: e.key, receivedQty: qty);
    }).toList();

    final result = await repo.receiveStock(
      poId: widget.poId,
      storeId: widget.storeId,
      receivedItems: receivedItems,
      employeeId: auth.currentEmployee?.id,
    );

    if (!mounted) return;
    result.when(
      success: (_) {
        showToast(
          context: context,
          builder: (_, _) => SurfaceCard(
            child: Basic(title: Text(t.inventory.stockReceived)),
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

