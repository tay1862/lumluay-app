import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../i18n/strings.g.dart';
import '../data/shift_providers.dart';

class OpenShiftDialog extends ConsumerStatefulWidget {
  final String storeId;
  const OpenShiftDialog({super.key, required this.storeId});

  @override
  ConsumerState<OpenShiftDialog> createState() => _OpenShiftDialogState();
}

class _OpenShiftDialogState extends ConsumerState<OpenShiftDialog> {
  final _amountCtl = TextEditingController(text: '0');
  bool _saving = false;

  @override
  void dispose() {
    _amountCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return AlertDialog(
      title: Text(t.shifts.openShift),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.shifts.openingCash, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            TextField(
              controller: _amountCtl,
              placeholder: Text(t.shifts.enterAmount),
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
          onPressed: _saving ? null : _open,
          child: Text(t.shifts.openShift),
        ),
      ],
    );
  }

  Future<void> _open() async {
    setState(() => _saving = true);
    final t = Translations.of(context);
    final repo = ref.read(shiftRepositoryProvider);
    final auth = ref.read(authProvider);
    final empId = auth.currentEmployee?.id ?? '';
    final amount = double.tryParse(_amountCtl.text) ?? 0;

    final result = await repo.openShift(
      storeId: widget.storeId,
      employeeId: empId,
      openingCash: amount,
    );

    if (!mounted) return;

    result.when(
      success: (_) {
        showToast(
          context: context,
          builder: (_, overlay) =>
              SurfaceCard(child: Basic(title: Text(t.shifts.shiftOpened))),
        );
        Navigator.of(context).pop();
      },
      failure: (e) {
        showToast(
          context: context,
          builder: (_, overlay) => SurfaceCard(
              child: Basic(title: Text(e.message))),
        );
        setState(() => _saving = false);
      },
    );
  }
}
