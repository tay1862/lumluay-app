import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/audit/audit_service.dart';
import '../../../core/providers/audit_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../i18n/strings.g.dart';
import '../../items/data/items_providers.dart';
import '../data/inventory_providers.dart';

class StockAdjustmentDialog extends ConsumerStatefulWidget {
  final String storeId;
  final String? preselectedItemId;
  final String? preselectedItemName;

  const StockAdjustmentDialog({
    super.key,
    required this.storeId,
    this.preselectedItemId,
    this.preselectedItemName,
  });

  @override
  ConsumerState<StockAdjustmentDialog> createState() =>
      _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState
    extends ConsumerState<StockAdjustmentDialog> {
  final _qtyController = TextEditingController();
  String? _selectedItemId;
  String? _selectedItemName;
  String _reason = 'correction';
  bool _isPositive = true;

  @override
  void initState() {
    super.initState();
    _selectedItemId = widget.preselectedItemId;
    _selectedItemName = widget.preselectedItemName;
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final itemsAsync = ref.watch(itemsStreamProvider(null));

    return AlertDialog(
      title: Text(t.inventory.adjustStock),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item selection
            if (_selectedItemId == null) ...[
              Text(t.items.allItems,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: itemsAsync.when(
                  data: (items) {
                    final tracked =
                        items.where((i) => i.trackStock).toList();
                    if (tracked.isEmpty) {
                      return Center(child: Text(t.inventory.noStockItems));
                    }
                    return ListView.builder(
                      itemCount: tracked.length,
                      itemBuilder: (context, index) {
                        final item = tracked[index];
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() {
                            _selectedItemId = item.id;
                            _selectedItemName = item.name;
                          }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 4),
                            child: Row(
                              children: [
                                const Icon(RadixIcons.cube, size: 14),
                                const SizedBox(width: 8),
                                Expanded(child: Text(item.name)),
                                if (item.sku != null)
                                  Text(item.sku!,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .mutedForeground)),
                              ],
                            ),
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
            ] else ...[
              // Selected item display
              Row(
                children: [
                  const Icon(RadixIcons.cube, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_selectedItemName ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                  if (widget.preselectedItemId == null)
                    Button(
                      style: const ButtonStyle.ghost(
                          density: ButtonDensity.compact),
                      onPressed: () => setState(() {
                        _selectedItemId = null;
                        _selectedItemName = null;
                      }),
                      child: Text(t.common.edit),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Direction toggle
              Row(
                children: [
                  Button(
                    style: _isPositive
                        ? const ButtonStyle.primary(
                            density: ButtonDensity.compact)
                        : const ButtonStyle.outline(
                            density: ButtonDensity.compact),
                    onPressed: () => setState(() => _isPositive = true),
                    child: const Text('+  Add'),
                  ),
                  const SizedBox(width: 8),
                  Button(
                    style: !_isPositive
                        ? const ButtonStyle.destructive(
                            density: ButtonDensity.compact)
                        : const ButtonStyle.outline(
                            density: ButtonDensity.compact),
                    onPressed: () => setState(() => _isPositive = false),
                    child: const Text('−  Remove'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quantity
              Text(t.inventory.quantity,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: _qtyController,
                placeholder: const Text('0'),
              ),
              const SizedBox(height: 12),

              // Reason
              Text(t.inventory.reason,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _reasonChip('correction', t.inventory.correction),
                  _reasonChip('damaged', t.inventory.damaged),
                  _reasonChip('lost', t.inventory.lost),
                  _reasonChip('received', t.inventory.received),
                  _reasonChip('returned', t.inventory.returned),
                  _reasonChip('other', t.inventory.other),
                ],
              ),
            ],
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
          onPressed: _selectedItemId != null ? _submit : null,
          child: Text(t.common.save),
        ),
      ],
    );
  }

  Widget _reasonChip(String value, String label) {
    return Button(
      style: _reason == value
          ? const ButtonStyle.primary(density: ButtonDensity.compact)
          : const ButtonStyle.outline(density: ButtonDensity.compact),
      onPressed: () => setState(() => _reason = value),
      child: Text(label),
    );
  }

  Future<void> _submit() async {
    final qty = double.tryParse(_qtyController.text);
    if (qty == null || qty <= 0 || _selectedItemId == null) return;

    final change = _isPositive ? qty : -qty;
    final repo = ref.read(inventoryRepositoryProvider);
    final auth = ref.read(authProvider);

    final result = await repo.adjustStock(
      storeId: widget.storeId,
      itemId: _selectedItemId!,
      quantityChange: change,
      reason: _reason,
      employeeId: auth.currentEmployee?.id,
    );

    result.when(
      success: (_) {
        ref.read(auditServiceProvider).log(
              storeId: widget.storeId,
              employeeId: auth.currentEmployee?.id,
              action: AuditAction.create,
              entityType: 'stock_adjustment',
              entityId: _selectedItemId!,
              newValues: {
                'quantity_change': change,
                'reason': _reason,
              },
            );
        final t = Translations.of(context);
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(title: Text(t.inventory.adjustmentCreated)),
          ),
          location: ToastLocation.bottomRight,
          showDuration: const Duration(seconds: 3),
        );
        Navigator.of(context).pop();
      },
      failure: (e) {
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(title: Text(e.message)),
          ),
          location: ToastLocation.bottomRight,
          showDuration: const Duration(seconds: 3),
        );
      },
    );
  }
}
