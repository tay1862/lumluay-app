import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/audit/audit_service.dart';
import '../../../core/providers/audit_provider.dart';
import '../../../i18n/strings.g.dart';
import '../data/sales_providers.dart';

class PaymentDialog extends ConsumerStatefulWidget {
  final String storeId;
  final String employeeId;

  const PaymentDialog({
    super.key,
    required this.storeId,
    required this.employeeId,
  });

  @override
  ConsumerState<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<PaymentDialog> {
  String _selectedMethod = 'cash';
  final TextEditingController _amountController = TextEditingController();
  bool _processing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final cart = ref.read(cartProvider);
    _amountController.text = cart.total.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _amountPaid => double.tryParse(_amountController.text) ?? 0;

  Future<void> _processPayment() async {
    final cart = ref.read(cartProvider);
    if (_amountPaid < cart.total && _selectedMethod == 'cash') {
      setState(() => _error = 'Insufficient amount');
      return;
    }

    setState(() {
      _processing = true;
      _error = null;
    });

    final repo = ref.read(salesRepositoryProvider);
    final result = await repo.createReceipt(
      storeId: widget.storeId,
      employeeId: widget.employeeId,
      cart: cart,
      paymentMethod: _selectedMethod,
      amountPaid: _amountPaid,
    );

    result.when(
      success: (receiptId) {
        ref.read(auditServiceProvider).log(
              storeId: widget.storeId,
              employeeId: widget.employeeId,
              action: AuditAction.create,
              entityType: 'receipt',
              entityId: receiptId,
            );

        ref.read(cartProvider.notifier).clear();

        if (mounted) {
          _showSuccessToast(cart.total);
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

  void _showSuccessToast(double total) {
    final t = Translations.of(context);
    showToast(
      context: context,
      builder: (context, overlay) => SurfaceCard(
        child: Basic(
          leading: const Icon(RadixIcons.checkCircled),
          title: Text('${t.common.success} — ₭${total.toStringAsFixed(0)}'),
        ),
      ),
      location: ToastLocation.bottomRight,
      showDuration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final cart = ref.watch(cartProvider);
    final changeDue = _amountPaid - cart.total;

    return AlertDialog(
      title: Text(t.sales.payNow),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total display
            Center(
              child: Text(
                '₭${cart.total.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Payment method buttons
            Text(t.sales.cashPayment,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                _methodButton('cash', t.sales.cashPayment, RadixIcons.backpack),
                const SizedBox(width: 8),
                _methodButton('qr', t.sales.qrPayment, LucideIcons.qrCode),
                const SizedBox(width: 8),
                _methodButton('card', t.sales.cardPayment, RadixIcons.cardStack),
              ],
            ),
            const SizedBox(height: 16),

            // Amount input (for cash)
            if (_selectedMethod == 'cash') ...[
              Text(t.common.amount,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                placeholder: const Text('0'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),

              // Quick amount buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickAmounts(cart.total).map((amt) {
                  return Button(
                    style: const ButtonStyle.outline(density: ButtonDensity.compact),
                    onPressed: () {
                      _amountController.text = amt.toStringAsFixed(0);
                      setState(() {});
                    },
                    child: Text('₭${amt.toStringAsFixed(0)}'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Change due
              if (changeDue > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t.sales.changeDue,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text('₭${changeDue.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: theme.colorScheme.primary,
                        )),
                  ],
                ),
            ],

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
          style: const ButtonStyle.primary(),
          onPressed: _processing ? null : _processPayment,
          child: _processing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(t.sales.payNow),
        ),
      ],
    );
  }

  Widget _methodButton(String method, String label, IconData icon) {
    final isSelected = _selectedMethod == method;
    return Expanded(
      child: Button(
        style: isSelected
            ? const ButtonStyle.primary()
            : const ButtonStyle.outline(),
        onPressed: () => setState(() => _selectedMethod = method),
        child: Column(
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  List<double> _quickAmounts(double total) {
    final rounded = (total / 1000).ceil() * 1000;
    return {
      total,
      rounded.toDouble(),
      (rounded + 5000).toDouble(),
      (rounded + 10000).toDouble(),
      (rounded + 50000).toDouble(),
    }.toList();
  }
}
