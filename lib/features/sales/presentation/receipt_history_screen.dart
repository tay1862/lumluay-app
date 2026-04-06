import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../i18n/strings.g.dart';
import '../data/sales_providers.dart';
import 'receipt_detail_dialog.dart';

class ReceiptHistoryScreen extends ConsumerStatefulWidget {
  const ReceiptHistoryScreen({super.key});

  @override
  ConsumerState<ReceiptHistoryScreen> createState() =>
      _ReceiptHistoryScreenState();
}

class _ReceiptHistoryScreenState extends ConsumerState<ReceiptHistoryScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider);
    final storeId = auth.currentStoreId;

    if (storeId == null) {
      return Center(child: Text(t.common.noData));
    }

    final receiptsAsync = ref.watch(receiptsStreamProvider(storeId));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(t.receipts.receiptHistory,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
              _filterChip('completed', t.receipts.completed),
              _filterChip('refunded', t.receipts.refunded),
              _filterChip('voided', t.receipts.voided),
            ],
          ),
          const SizedBox(height: 16),

          // Receipts list
          Expanded(
            child: receiptsAsync.when(
              data: (receipts) {
                var filtered = receipts;

                // Filter by status
                if (_statusFilter != 'all') {
                  filtered = filtered
                      .where((r) => r.status == _statusFilter)
                      .toList();
                }

                // Filter by search
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  filtered = filtered
                      .where((r) =>
                          r.receiptNumber.toLowerCase().contains(q) ||
                          (r.customerId?.toLowerCase().contains(q) ?? false))
                      .toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(t.receipts.noReceipts,
                        style: TextStyle(
                            color: theme.colorScheme.mutedForeground)),
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final receipt = filtered[index];
                    return _ReceiptListTile(
                      receipt: receipt,
                      onTap: () => _showReceiptDetail(receipt),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Button(
        style: _statusFilter == value
            ? const ButtonStyle.primary(density: ButtonDensity.compact)
            : const ButtonStyle.outline(density: ButtonDensity.compact),
        onPressed: () => setState(() => _statusFilter = value),
        child: Text(label),
      ),
    );
  }

  void _showReceiptDetail(Receipt receipt) {
    showDialog(
      context: context,
      builder: (_) => ReceiptDetailDialog(receipt: receipt),
    );
  }
}

// ── Receipt list tile ──
class _ReceiptListTile extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onTap;

  const _ReceiptListTile({required this.receipt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            // Receipt icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _statusColor(receipt.status, theme).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _statusIcon(receipt.status),
                size: 18,
                color: _statusColor(receipt.status, theme),
              ),
            ),
            const SizedBox(width: 12),

            // Receipt info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#${receipt.receiptNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    _formatDateTime(receipt.createdAt),
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.mutedForeground),
                  ),
                ],
              ),
            ),

            // Status badge
            _StatusBadge(status: receipt.status),
            const SizedBox(width: 12),

            // Total
            Text(
              '₭${receipt.total.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: receipt.total < 0
                    ? theme.colorScheme.destructive
                    : theme.colorScheme.foreground,
              ),
            ),
            const SizedBox(width: 8),
            Icon(RadixIcons.chevronRight,
                size: 14, color: theme.colorScheme.mutedForeground),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status, ThemeData theme) {
    return switch (status) {
      'completed' => theme.colorScheme.primary,
      'voided' => theme.colorScheme.destructive,
      'refunded' || 'refund' => Colors.orange,
      _ => theme.colorScheme.mutedForeground,
    };
  }

  IconData _statusIcon(String status) {
    return switch (status) {
      'completed' => RadixIcons.checkCircled,
      'voided' => RadixIcons.crossCircled,
      'refunded' || 'refund' => RadixIcons.reset,
      _ => RadixIcons.file,
    };
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── Status badge ──
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    final (label, color) = switch (status) {
      'completed' => (t.receipts.completed, theme.colorScheme.primary),
      'voided' => (t.receipts.voided, theme.colorScheme.destructive),
      'refunded' => (t.receipts.refunded, Colors.orange),
      'refund' => (t.sales.refund, Colors.orange),
      _ => (status, theme.colorScheme.mutedForeground),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    );
  }
}
