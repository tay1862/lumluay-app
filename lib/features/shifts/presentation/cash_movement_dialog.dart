import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../i18n/strings.g.dart';
import '../data/shift_providers.dart';

class CashMovementDialog extends ConsumerStatefulWidget {
  final String shiftId;
  final String type; // 'in' or 'out'

  const CashMovementDialog({
    super.key,
    required this.shiftId,
    required this.type,
  });

  @override
  ConsumerState<CashMovementDialog> createState() =>
      _CashMovementDialogState();
}

class _CashMovementDialogState extends ConsumerState<CashMovementDialog> {
  final _amountCtl = TextEditingController();
  final _reasonCtl = TextEditingController();
  bool _saving = false;

  bool get _isIn => widget.type == 'in';

  @override
  void dispose() {
    _amountCtl.dispose();
    _reasonCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return AlertDialog(
      title: Text(_isIn ? t.shifts.cashIn : t.shifts.cashOut),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.shifts.amount, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            TextField(
              controller: _amountCtl,
              placeholder: Text(t.shifts.enterAmount),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Text(t.shifts.reason, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            TextField(
              controller: _reasonCtl,
              placeholder: Text(t.shifts.reason),
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
          onPressed: _saving ? null : _submit,
          child: Text(t.common.save),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtl.text);
    if (amount == null || amount <= 0) return;

    setState(() => _saving = true);
    final t = Translations.of(context);
    final repo = ref.read(shiftRepositoryProvider);

    await repo.addCashMovement(
      shiftId: widget.shiftId,
      type: widget.type,
      amount: amount,
      reason: _reasonCtl.text.trim(),
    );

    if (!mounted) return;

    showToast(
      context: context,
      builder: (_, overlay) => SurfaceCard(
        child: Basic(
            title: Text(_isIn ? t.shifts.cashAdded : t.shifts.cashRemoved)),
      ),
    );
    Navigator.of(context).pop();
  }
}
