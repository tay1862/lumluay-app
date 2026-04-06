import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../i18n/strings.g.dart';
import '../data/inventory_providers.dart';
import '../data/inventory_repository.dart';
import 'stock_adjustment_dialog.dart';
import 'inventory_count_dialog.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _searchQuery = '';
  String _filter = 'all'; // all, low, out

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider);
    final storeId = auth.currentStoreId ?? '';

    final stockAsync = ref.watch(stockLevelsProvider(storeId));
    final valuationAsync = ref.watch(inventoryValuationProvider(storeId));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Text(t.inventory.stockLevels,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              // Valuation badge
              valuationAsync.when(
                data: (value) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.muted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${t.inventory.totalValue}: ₭${value.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(width: 8),
              Button(
                style:
                    const ButtonStyle.outline(density: ButtonDensity.compact),
                onPressed: () => _showInventoryCount(storeId),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(RadixIcons.clipboardCopy, size: 14),
                    const SizedBox(width: 4),
                    Text(t.inventory.stockCount),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Button(
                style:
                    const ButtonStyle.primary(density: ButtonDensity.compact),
                onPressed: () => _showAdjustStock(storeId),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(RadixIcons.plusCircled, size: 14),
                    const SizedBox(width: 4),
                    Text(t.inventory.adjustStock),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Button(
                style:
                    const ButtonStyle.outline(density: ButtonDensity.compact),
                onPressed: () => context.push('/inventory/purchase-orders'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(RadixIcons.reader, size: 14),
                    const SizedBox(width: 4),
                    Text(t.inventory.purchaseOrders),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Button(
                style:
                    const ButtonStyle.outline(density: ButtonDensity.compact),
                onPressed: () => context.push('/inventory/transfers'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(RadixIcons.shuffle, size: 14),
                    const SizedBox(width: 4),
                    Text(t.inventory.transfers),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Button(
                style:
                    const ButtonStyle.outline(density: ButtonDensity.compact),
                onPressed: () => context.push('/inventory/production'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(RadixIcons.mix, size: 14),
                    const SizedBox(width: 4),
                    Text(t.production.title),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search + filter row
          Row(
            children: [
              SizedBox(
                width: 280,
                child: TextField(
                  placeholder: Text(t.common.search),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(width: 12),
              _filterChip('all', t.common.all),
              _filterChip('low', t.inventory.lowStock),
              _filterChip('out', t.inventory.outOfStock),
            ],
          ),
          const SizedBox(height: 12),

          // Stock list
          Expanded(
            child: stockAsync.when(
              data: (stocks) {
                final filtered = _applyFilters(stocks);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(t.inventory.noStockItems,
                        style: TextStyle(
                            color: theme.colorScheme.mutedForeground)),
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final stock = filtered[index];
                    return _StockRow(
                      stock: stock,
                      onAdjust: () => _showAdjustStockForItem(
                          storeId, stock.level.itemId, stock.itemName),
                      onSetThreshold: () => _showSetThreshold(
                          storeId, stock.level.itemId, stock.level.lowStockThreshold),
                    );
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

  List<InventoryStock> _applyFilters(List<InventoryStock> stocks) {
    var result = stocks;

    // Text search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((s) =>
              s.itemName.toLowerCase().contains(q) ||
              (s.sku?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    // Status filter
    switch (_filter) {
      case 'low':
        result = result.where((s) => s.isLowStock).toList();
      case 'out':
        result = result.where((s) => s.isOutOfStock).toList();
    }

    return result;
  }

  Widget _filterChip(String id, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Button(
        style: _filter == id
            ? const ButtonStyle.primary(density: ButtonDensity.compact)
            : const ButtonStyle.outline(density: ButtonDensity.compact),
        onPressed: () => setState(() => _filter = id),
        child: Text(label),
      ),
    );
  }

  void _showAdjustStock(String storeId) {
    showDialog(
      context: context,
      builder: (_) => StockAdjustmentDialog(storeId: storeId),
    );
  }

  void _showAdjustStockForItem(
      String storeId, String itemId, String itemName) {
    showDialog(
      context: context,
      builder: (_) => StockAdjustmentDialog(
        storeId: storeId,
        preselectedItemId: itemId,
        preselectedItemName: itemName,
      ),
    );
  }

  void _showInventoryCount(String storeId) {
    showDialog(
      context: context,
      builder: (_) => InventoryCountDialog(storeId: storeId),
    );
  }

  void _showSetThreshold(
      String storeId, String itemId, double currentThreshold) {
    final controller =
        TextEditingController(text: currentThreshold.toStringAsFixed(0));
    final t = Translations.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.inventory.setThreshold),
        content: SizedBox(
          width: 300,
          child: TextField(
            controller: controller,
            placeholder: Text(t.inventory.threshold),
          ),
        ),
        actions: [
          Button(
            style: const ButtonStyle.outline(),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.common.cancel),
          ),
          Button(
            style: const ButtonStyle.primary(),
            onPressed: () async {
              final value = double.tryParse(controller.text) ?? 0;
              final repo = ref.read(inventoryRepositoryProvider);
              await repo.setLowStockThreshold(storeId, itemId, value);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(t.common.save),
          ),
        ],
      ),
    );
  }
}

// ── Stock Row ──
class _StockRow extends StatelessWidget {
  final InventoryStock stock;
  final VoidCallback onAdjust;
  final VoidCallback onSetThreshold;

  const _StockRow({
    required this.stock,
    required this.onAdjust,
    required this.onSetThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final statusColor = stock.isOutOfStock
        ? theme.colorScheme.destructive
        : stock.isLowStock
            ? Colors.orange
            : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Item info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stock.itemName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (stock.sku != null && stock.sku!.isNotEmpty)
                  Text(stock.sku!,
                      style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.mutedForeground)),
              ],
            ),
          ),

          // Quantity
          SizedBox(
            width: 80,
            child: Text(
              stock.level.quantity.toStringAsFixed(
                  stock.level.quantity == stock.level.quantity.roundToDouble()
                      ? 0
                      : 1),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Threshold badge
          if (stock.level.lowStockThreshold > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.muted,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '≤${stock.level.lowStockThreshold.toStringAsFixed(0)}',
                style: TextStyle(
                    fontSize: 11, color: theme.colorScheme.mutedForeground),
              ),
            ),
          const SizedBox(width: 8),

          // Value
          SizedBox(
            width: 90,
            child: Text(
              '₭${stock.stockValue.toStringAsFixed(0)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 12, color: theme.colorScheme.mutedForeground),
            ),
          ),
          const SizedBox(width: 8),

          // Actions
          Button(
            style: const ButtonStyle.ghost(density: ButtonDensity.compact),
            onPressed: onSetThreshold,
            child: const Icon(RadixIcons.bell, size: 14),
          ),
          Button(
            style: const ButtonStyle.ghost(density: ButtonDensity.compact),
            onPressed: onAdjust,
            child: const Icon(RadixIcons.pencil1, size: 14),
          ),
        ],
      ),
    );
  }
}
