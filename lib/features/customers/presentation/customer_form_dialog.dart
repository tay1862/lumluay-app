import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../i18n/strings.g.dart';
import '../data/customer_providers.dart';

class CustomerFormDialog extends ConsumerStatefulWidget {
  final String storeId;
  final Customer? customer;

  const CustomerFormDialog({
    super.key,
    required this.storeId,
    this.customer,
  });

  @override
  ConsumerState<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends ConsumerState<CustomerFormDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _notesCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.customer?.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.customer?.phone ?? '');
    _emailCtrl = TextEditingController(text: widget.customer?.email ?? '');
    _addressCtrl =
        TextEditingController(text: widget.customer?.address ?? '');
    _notesCtrl = TextEditingController(text: widget.customer?.notes ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isEditing = widget.customer != null;

    return AlertDialog(
      title:
          Text(isEditing ? t.customers.editCustomer : t.customers.addCustomer),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              placeholder: Text(t.customers.customerName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              placeholder: Text(t.customers.phone),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              placeholder: Text(t.customers.email),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressCtrl,
              placeholder: Text(t.customers.address),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              placeholder: Text(t.customers.notes),
              maxLines: 3,
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
          onPressed: _saving ? null : _save,
          child: Text(t.common.save),
        ),
      ],
    );
  }

  void _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final t = Translations.of(context);
    final repo = ref.read(customerRepositoryProvider);

    final result = widget.customer != null
        ? await repo.updateCustomer(
            id: widget.customer!.id,
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim().isEmpty
                ? null
                : _phoneCtrl.text.trim(),
            email: _emailCtrl.text.trim().isEmpty
                ? null
                : _emailCtrl.text.trim(),
            address: _addressCtrl.text.trim().isEmpty
                ? null
                : _addressCtrl.text.trim(),
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
          )
        : await repo.createCustomer(
            storeId: widget.storeId,
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim().isEmpty
                ? null
                : _phoneCtrl.text.trim(),
            email: _emailCtrl.text.trim().isEmpty
                ? null
                : _emailCtrl.text.trim(),
            address: _addressCtrl.text.trim().isEmpty
                ? null
                : _addressCtrl.text.trim(),
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
          );

    if (!mounted) return;
    result.when(
      success: (_) {
        final msg = widget.customer != null
            ? t.customers.customerUpdated
            : t.customers.customerCreated;
        showToast(
          context: context,
          builder: (_, _) => SurfaceCard(
            child: Basic(title: Text(msg)),
          ),
          location: ToastLocation.bottomRight,
          showDuration: const Duration(seconds: 2),
        );
        Navigator.of(context).pop();
      },
      failure: (e) {
        showToast(
          context: context,
          builder: (_, _) =>
              SurfaceCard(child: Basic(title: Text(e.message))),
          location: ToastLocation.bottomRight,
          showDuration: const Duration(seconds: 3),
        );
        setState(() => _saving = false);
      },
    );
  }
}
