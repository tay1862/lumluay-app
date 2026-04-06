import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/audit/audit_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/audit_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../i18n/strings.g.dart';
import '../data/receipt_printer_service.dart';
import '../data/sales_providers.dart';
import 'refund_dialog.dart';

class ReceiptDetailDialog extends ConsumerWidget {
  final Receipt receipt;

  const ReceiptDetailDialog({super.key, required this.receipt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final itemsAsync = ref.watch(receiptItemsProvider(receipt.id));
    final paymentsAsync = ref.watch(receiptPaymentsProvider(receipt.id));
    final isRefundable = receipt.status == 'completed';

    return AlertDialog(
      title: Text('${t.sales.receiptNumber}${receipt.receiptNumber}'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status + datetime
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusChip(status: receipt.status),
                Text(
                  _formatDateTime(receipt.createdAt),
                  style: TextStyle(
                      fontSize: 12, color: theme.colorScheme.mutedForeground),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Items
            Text(t.items.allItems,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            itemsAsync.when(
              data: (items) => Column(
                children: items.map((item) => _ItemRow(item: item)).toList(),
              ),
              loading: () => const SizedBox(
                  height: 40,
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('$e'),
            ),
            const Divider(),

            // Totals
            _AmountRow(t.common.subtotal, receipt.subtotal),
            if (receipt.discountTotal > 0)
              _AmountRow(t.common.discount, -receipt.discountTotal,
                  isNegative: true),
            if (receipt.taxTotal > 0)
              _AmountRow(t.common.tax, receipt.taxTotal),
            const SizedBox(height: 4),
            _AmountRow(t.common.total, receipt.total, isBold: true),
            const SizedBox(height: 12),

            // Payments
            Text(t.receipts.paidWith,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            paymentsAsync.when(
              data: (payments) => Column(
                children: payments
                    .map((p) => _PaymentRow(payment: p))
                    .toList(),
              ),
              loading: () => const SizedBox(height: 20),
              error: (e, _) => Text('$e'),
            ),
          ],
        ),
      ),
      actions: [
        // Print & share
        Button(
          style: const ButtonStyle.outline(density: ButtonDensity.compact),
          onPressed: () => _handlePrint(context, ref),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(RadixIcons.share1, size: 14),
              const SizedBox(width: 4),
              Text(t.receipts.printReceipt),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Button(
          style: const ButtonStyle.outline(density: ButtonDensity.compact),
          onPressed: () => _handleShare(context, ref),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(RadixIcons.download, size: 14),
              const SizedBox(width: 4),
              Text(t.receipts.shareReceipt),
            ],
          ),
        ),
        const Spacer(),
        if (isRefundable) ...[
          Button(
            style: const ButtonStyle.destructive(
                density: ButtonDensity.compact),
            onPressed: () => _handleVoid(context, ref),
            child: Text(t.sales.voidReceipt),
          ),
          const SizedBox(width: 4),
          Button(
            style:
                const ButtonStyle.outline(density: ButtonDensity.compact),
            onPressed: () => _handleRefund(context, ref),
            child: Text(t.sales.refund),
          ),
        ],
        const SizedBox(width: 4),
        Button(
          style: const ButtonStyle.primary(density: ButtonDensity.compact),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.close),
        ),
      ],
    );
  }

  void _handlePrint(BuildContext context, WidgetRef ref) async {
    final receiptData = await ref.read(receiptDataProvider(receipt.id).future);
    if (receiptData == null || !context.mounted) return;
    await ReceiptPrinterService.printReceipt(receiptData);
  }

  void _handleShare(BuildContext context, WidgetRef ref) async {
    final receiptData = await ref.read(receiptDataProvider(receipt.id).future);
    if (receiptData == null || !context.mounted) return;
    await ReceiptPrinterService.shareReceipt(receiptData);
  }

  void _handleVoid(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.sales.voidReceipt),
        content: Text(t.receipts.confirmVoid),
        actions: [
          Button(
            style: const ButtonStyle.outline(),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.common.cancel),
          ),
          Button(
            style: const ButtonStyle.destructive(),
            onPressed: () async {
              final repo = ref.read(salesRepositoryProvider);
              final auth = ref.read(authProvider);
              final result = await repo.voidReceipt(receipt.id);
              result.when(
                success: (_) {
                  ref.read(auditServiceProvider).log(
                        storeId: receipt.storeId,
                        employeeId: auth.currentEmployee?.id,
                        action: AuditAction.update,
                        entityType: 'receipt',
                        entityId: receipt.id,
                        newValues: {'status': 'voided'},
                      );
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                  _showToast(context, t.common.success);
                },
                failure: (e) {
                  Navigator.of(ctx).pop();
                  _showToast(context, e.message);
                },
              );
            },
            child: Text(t.sales.voidReceipt),
          ),
        ],
      ),
    );
  }

  void _handleRefund(BuildContext context, WidgetRef ref) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (_) => RefundDialog(receipt: receipt),
    );
  }

  void _showToast(BuildContext context, String message) {
    showToast(
      context: context,
      builder: (context, overlay) => SurfaceCard(
        child: Basic(title: Text(message)),
      ),
      location: ToastLocation.bottomRight,
      showDuration: const Duration(seconds: 3),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── Status chip ──
class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Item row ──
class _ItemRow extends StatelessWidget {
  final ReceiptItem item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(item.name,
                style: const TextStyle(fontSize: 13)),
          ),
          Text('×${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)}',
              style: TextStyle(
                  fontSize: 12, color: theme.colorScheme.mutedForeground)),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text('₭${item.total.toStringAsFixed(0)}',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ── Amount row ──
class _AmountRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBold;
  final bool isNegative;

  const _AmountRow(this.label, this.amount,
      {this.isBold = false, this.isNegative = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isBold ? 15 : 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            '${isNegative ? '-' : ''}₭${amount.abs().toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isNegative
                  ? Theme.of(context).colorScheme.destructive
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payment row ──
class _PaymentRow extends StatelessWidget {
  final Payment payment;

  const _PaymentRow({required this.payment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    final methodLabel = switch (payment.method) {
      'cash' => t.sales.cashPayment,
      'qr' => t.sales.qrPayment,
      'card' => t.sales.cardPayment,
      _ => t.sales.otherPayment,
    };

    final methodIcon = switch (payment.method) {
      'cash' => RadixIcons.backpack,
      'qr' => LucideIcons.qrCode,
      'card' => RadixIcons.cardStack,
      _ => RadixIcons.questionMarkCircled,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(methodIcon, size: 14, color: theme.colorScheme.mutedForeground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(methodLabel, style: const TextStyle(fontSize: 13)),
          ),
          Text('₭${payment.amount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
