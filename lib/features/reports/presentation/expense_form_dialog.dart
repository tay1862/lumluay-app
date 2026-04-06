import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../i18n/strings.g.dart';
import '../data/report_providers.dart';

class ExpenseFormDialog extends ConsumerStatefulWidget {
  const ExpenseFormDialog({super.key});

  @override
  ConsumerState<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends ConsumerState<ExpenseFormDialog> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return AlertDialog(
      title: Text(t.reports.addExpense),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descController,
              placeholder: Text(t.common.description),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              placeholder: Text(t.common.amount),
              keyboardType: TextInputType.number,
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
          onPressed: _save,
          child: Text(t.common.save),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final desc = _descController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (desc.isEmpty || amount <= 0) return;

    final storeId = ref.read(authProvider).currentStoreId;
    if (storeId == null) return;

    await ref.read(expenseRepositoryProvider).createExpense(
          storeId: storeId,
          description: desc,
          amount: amount,
          date: DateTime.now(),
        );

    if (mounted) Navigator.of(context).pop(true);
  }
}
