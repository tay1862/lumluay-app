import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../i18n/strings.g.dart';
import '../data/shift_providers.dart';

class CloseShiftDialog extends ConsumerStatefulWidget {
  final Shift shift;
  const CloseShiftDialog({super.key, required this.shift});

  @override
  ConsumerState<CloseShiftDialog> createState() => _CloseShiftDialogState();
}

class _CloseShiftDialogState extends ConsumerState<CloseShiftDialog> {
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
      title: Text(t.shifts.closeShift),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.shifts.openingCash, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Text('₭${widget.shift.openingCash.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(t.shifts.closingCash,
                style: const TextStyle(fontSize: 13)),
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
          style: const ButtonStyle.destructive(),
          onPressed: _saving ? null : _close,
          child: Text(t.shifts.closeShift),
        ),
      ],
    );
  }

  Future<void> _close() async {
    setState(() => _saving = true);
    final t = Translations.of(context);
    final repo = ref.read(shiftRepositoryProvider);
    final amount = double.tryParse(_amountCtl.text) ?? 0;

    final result = await repo.closeShift(
      shiftId: widget.shift.id,
      closingCash: amount,
    );

    if (!mounted) return;

    result.when(
      success: (_) {
        showToast(
          context: context,
          builder: (_, overlay) =>
              SurfaceCard(child: Basic(title: Text(t.shifts.shiftClosed))),
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
