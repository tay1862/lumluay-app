import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../i18n/strings.g.dart';
import '../data/inventory_providers.dart';

class InventoryCountDialog extends ConsumerStatefulWidget {
  final String storeId;

  const InventoryCountDialog({super.key, required this.storeId});

  @override
  ConsumerState<InventoryCountDialog> createState() =>
      _InventoryCountDialogState();
}

class _InventoryCountDialogState extends ConsumerState<InventoryCountDialog> {
  String? _countId;
  bool _creating = false;
  final Map<String, TextEditingController> _controllers = {};

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

    if (_countId == null) {
      return _buildStartScreen(t, theme);
    }

    return _buildCountScreen(t, theme);
  }

  Widget _buildStartScreen(Translations t, ThemeData theme) {
    // Show existing in-progress counts or start new
    final countsAsync = ref.watch(inventoryCountsProvider(widget.storeId));

    return AlertDialog(
      title: Text(t.inventory.stockCount),
      content: SizedBox(
        width: 500,
        height: 300,
        child: countsAsync.when(
          data: (counts) {
            final inProgress =
                counts.where((c) => c.status == 'in_progress').toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (inProgress.isNotEmpty) ...[
                  Text('In Progress',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: inProgress.length,
                      itemBuilder: (context, index) {
                        final count = inProgress[index];
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              setState(() => _countId = count.id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                const Icon(RadixIcons.clipboardCopy,
                                    size: 14),
                                const SizedBox(width: 8),
                                Text(_formatDate(count.createdAt)),
                                const Spacer(),
                                const Icon(RadixIcons.chevronRight,
                                    size: 14),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ] else
                  Expanded(
                    child: Center(
                      child: Text(
                        'No counts in progress',
                        style: TextStyle(
                            color: theme.colorScheme.mutedForeground),
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
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
          onPressed: _creating ? null : _startNewCount,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_creating)
                const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator()),
              if (_creating) const SizedBox(width: 8),
              Text(t.inventory.startCount),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountScreen(Translations t, ThemeData theme) {
    final countItemsAsync = ref.watch(countItemsProvider(_countId!));

    return AlertDialog(
      title: Text(t.inventory.stockCount),
      content: SizedBox(
        width: 600,
        height: 500,
        child: countItemsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return Center(
                child: Text(t.inventory.noStockItems,
                    style:
                        TextStyle(color: theme.colorScheme.mutedForeground)),
              );
            }

            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 3,
                          child: Text('Item',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12))),
                      SizedBox(
                          width: 80,
                          child: Text(t.inventory.expected,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12))),
                      SizedBox(
                          width: 100,
                          child: Text(t.inventory.counted,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12))),
                      SizedBox(
                          width: 70,
                          child: Text(t.inventory.difference,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12))),
                    ],
                  ),
                ),
                const Divider(),

                // Count items
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final ci = items[index];
                      return _CountItemRow(
                        countItem: ci,
                        controller: _getController(ci),
                        onChanged: (val) =>
                            _updateCounted(ci.id, val),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
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
          onPressed: _completeCount,
          child: Text(t.inventory.applyCount),
        ),
      ],
    );
  }

  TextEditingController _getController(InventoryCountItem ci) {
    return _controllers.putIfAbsent(ci.id, () {
      return TextEditingController(
        text: ci.countedQty?.toStringAsFixed(0) ?? '',
      );
    });
  }

  Future<void> _startNewCount() async {
    setState(() => _creating = true);
    final repo = ref.read(inventoryRepositoryProvider);
    final result = await repo.createInventoryCount(widget.storeId);
    result.when(
      success: (id) => setState(() {
        _countId = id;
        _creating = false;
      }),
      failure: (e) {
        setState(() => _creating = false);
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

  void _updateCounted(String countItemId, String value) {
    final qty = double.tryParse(value);
    if (qty == null) return;
    ref.read(inventoryRepositoryProvider).updateCountedQty(countItemId, qty);
  }

  Future<void> _completeCount() async {
    final repo = ref.read(inventoryRepositoryProvider);
    final auth = ref.read(authProvider);
    final result = await repo.completeInventoryCount(
      _countId!,
      widget.storeId,
      auth.currentEmployee?.id,
    );

    result.when(
      success: (_) {
        final t = Translations.of(context);
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(title: Text(t.inventory.countCompleted)),
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

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── Count Item Row ──
class _CountItemRow extends StatelessWidget {
  final InventoryCountItem countItem;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _CountItemRow({
    required this.countItem,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diff = (countItem.countedQty ?? 0) - countItem.expectedQty;
    final hasCounted = countItem.countedQty != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Item name — we'll show the ID for now; ideally join with items table
          Expanded(
            flex: 3,
            child: Text(countItem.itemId,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis),
          ),

          // Expected
          SizedBox(
            width: 80,
            child: Text(
              countItem.expectedQty.toStringAsFixed(0),
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 13, color: theme.colorScheme.mutedForeground),
            ),
          ),

          // Counted input
          SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: controller,
                placeholder: const Text('—'),
                onChanged: onChanged,
              ),
            ),
          ),

          // Difference
          SizedBox(
            width: 70,
            child: Text(
              hasCounted
                  ? (diff >= 0 ? '+${diff.toStringAsFixed(0)}' : diff.toStringAsFixed(0))
                  : '—',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: !hasCounted
                    ? theme.colorScheme.mutedForeground
                    : diff < 0
                        ? theme.colorScheme.destructive
                        : diff > 0
                            ? theme.colorScheme.primary
                            : theme.colorScheme.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
