import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/audit/audit_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/audit_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../i18n/strings.g.dart';
import '../data/sales_providers.dart';

class RefundDialog extends ConsumerStatefulWidget {
  final Receipt receipt;

  const RefundDialog({super.key, required this.receipt});

  @override
  ConsumerState<RefundDialog> createState() => _RefundDialogState();
}

class _RefundDialogState extends ConsumerState<RefundDialog> {
  final TextEditingController _reasonController = TextEditingController();
  bool _processing = false;
  String? _error;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _processRefund() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = Translations.of(context).receipts.refundReasonHint);
      return;
    }

    setState(() {
      _processing = true;
      _error = null;
    });

    final auth = ref.read(authProvider);
    final repo = ref.read(salesRepositoryProvider);
    final result = await repo.refundReceipt(
      widget.receipt.id,
      employeeId: auth.currentEmployee?.id ?? '',
      reason: reason,
    );

    result.when(
      success: (refundId) {
        ref.read(auditServiceProvider).log(
              storeId: widget.receipt.storeId,
              employeeId: auth.currentEmployee?.id,
              action: AuditAction.create,
              entityType: 'refund',
              entityId: refundId,
              newValues: {
                'originalReceiptId': widget.receipt.id,
                'reason': reason,
                'amount': widget.receipt.total,
              },
            );

        if (mounted) {
          final t = Translations.of(context);
          showToast(
            context: context,
            builder: (context, overlay) => SurfaceCard(
              child: Basic(
                leading: const Icon(RadixIcons.checkCircled),
                title: Text(t.receipts.refundProcessed),
              ),
            ),
            location: ToastLocation.bottomRight,
            showDuration: const Duration(seconds: 3),
          );
          Navigator.of(context).pop();
        }
      },
      failure: (error) {
        if (mounted) {
          setState(() {
            _processing = false;
            _error = error.message;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(t.receipts.refundReceipt),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Receipt info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${t.sales.receiptNumber}${widget.receipt.receiptNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text('₭${widget.receipt.total.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: theme.colorScheme.destructive,
                    )),
              ],
            ),
            const SizedBox(height: 16),

            // Refund amount display
            Center(
              child: Column(
                children: [
                  Text(t.receipts.refundAmount,
                      style: TextStyle(
                          color: theme.colorScheme.mutedForeground,
                          fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    '₭${widget.receipt.total.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.destructive,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Reason input
            Text(t.receipts.refundReason,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              placeholder: Text(t.receipts.refundReasonHint),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),

            // Error
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: TextStyle(color: theme.colorScheme.destructive)),
            ],
          ],
        ),
      ),
      actions: [
        Button(
          style: const ButtonStyle.outline(),
          onPressed: _processing ? null : () => Navigator.of(context).pop(),
          child: Text(t.common.cancel),
        ),
        const SizedBox(width: 8),
        Button(
          style: const ButtonStyle.destructive(),
          onPressed: _processing ? null : _processRefund,
          child: _processing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(t.receipts.fullRefund),
        ),
      ],
    );
  }
}
