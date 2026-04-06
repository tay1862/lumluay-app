import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/result.dart';
import '../../../i18n/strings.g.dart';
import '../data/inventory_providers.dart';

class SupplierListDialog extends ConsumerWidget {
  final String storeId;
  const SupplierListDialog({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final suppliersAsync = ref.watch(suppliersProvider(storeId));

    return AlertDialog(
      title: Text(t.inventory.suppliers),
      content: SizedBox(
        width: 450,
        height: 400,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Button(
                style: const ButtonStyle.primary(),
                onPressed: () => _showAddSupplier(context, ref),
                leading: const Icon(RadixIcons.plus),
                child: Text(t.inventory.addSupplier),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: suppliersAsync.when(
                data: (suppliers) {
                  if (suppliers.isEmpty) {
                    return Center(
                      child: Text(t.inventory.noSuppliers,
                          style: TextStyle(
                              color: theme.colorScheme.mutedForeground)),
                    );
                  }
                  return ListView.separated(
                    itemCount: suppliers.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final s = suppliers[index];
                      return _SupplierRow(supplier: s, storeId: storeId);
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
      ),
      actions: [
        Button(
          style: const ButtonStyle.outline(),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.close),
        ),
      ],
    );
  }

  void _showAddSupplier(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => SupplierFormDialog(storeId: storeId),
    );
  }
}

class _SupplierRow extends ConsumerWidget {
  final Supplier supplier;
  final String storeId;

  const _SupplierRow({required this.supplier, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(RadixIcons.person, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(supplier.name,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                if (supplier.phone != null)
                  Text(supplier.phone!,
                      style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.mutedForeground)),
              ],
            ),
          ),
          IconButton.ghost(
            icon: const Icon(RadixIcons.pencil1, size: 16),
            onPressed: () => _editSupplier(context, ref),
          ),
          IconButton.ghost(
            icon: const Icon(RadixIcons.trash, size: 16),
            onPressed: () => _deleteSupplier(context, ref),
          ),
        ],
      ),
    );
  }

  void _editSupplier(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) =>
          SupplierFormDialog(storeId: storeId, supplier: supplier),
    );
  }

  void _deleteSupplier(BuildContext context, WidgetRef ref) async {
    final t = Translations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.common.confirm),
        content: Text(t.common.confirm),
        actions: [
          Button(
            style: const ButtonStyle.outline(),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.common.cancel),
          ),
          Button(
            style: const ButtonStyle.destructive(),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.common.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final repo = ref.read(purchaseOrderRepositoryProvider);
      await repo.deleteSupplier(supplier.id);
    }
  }
}

// ── Add/Edit Supplier Form ──

class SupplierFormDialog extends ConsumerStatefulWidget {
  final String storeId;
  final Supplier? supplier;

  const SupplierFormDialog({
    super.key,
    required this.storeId,
    this.supplier,
  });

  @override
  ConsumerState<SupplierFormDialog> createState() => _SupplierFormDialogState();
}

class _SupplierFormDialogState extends ConsumerState<SupplierFormDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.supplier?.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.supplier?.phone ?? '');
    _emailCtrl = TextEditingController(text: widget.supplier?.email ?? '');
    _addressCtrl =
        TextEditingController(text: widget.supplier?.address ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isEditing = widget.supplier != null;

    return AlertDialog(
      title: Text(isEditing ? t.inventory.editSupplier : t.inventory.addSupplier),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              placeholder: Text(t.inventory.supplierName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              placeholder: Text(t.inventory.phone),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              placeholder: Text(t.inventory.email),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressCtrl,
              placeholder: Text(t.inventory.address),
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

    final repo = ref.read(purchaseOrderRepositoryProvider);
    final Result result;

    if (widget.supplier != null) {
      result = await repo.updateSupplier(
        id: widget.supplier!.id,
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        address:
            _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      );
    } else {
      result = await repo.createSupplier(
        storeId: widget.storeId,
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        address:
            _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      );
    }

    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.of(context).pop();
    } else {
      setState(() => _saving = false);
    }
  }
}
