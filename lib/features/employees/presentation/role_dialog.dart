import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../i18n/strings.g.dart';
import '../data/employee_providers.dart';

class RoleDialog extends ConsumerWidget {
  final String storeId;
  const RoleDialog({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final rolesAsync = ref.watch(rolesProvider(storeId));

    return AlertDialog(
      title: Text(t.employees.roles),
      content: SizedBox(
        width: 380,
        height: 340,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Button(
                style: const ButtonStyle.primary(
                    density: ButtonDensity.compact),
                onPressed: () => _showRoleForm(context, ref),
                leading: const Icon(RadixIcons.plus),
                child: Text(t.employees.addRole),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: rolesAsync.when(
                data: (roles) {
                  if (roles.isEmpty) {
                    return Center(
                      child: Text(t.employees.noRoles,
                          style: TextStyle(
                              color: theme.colorScheme.mutedForeground)),
                    );
                  }
                  return ListView.separated(
                    itemCount: roles.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (_, index) => _RoleRow(
                      role: roles[index],
                      storeId: storeId,
                    ),
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

  void _showRoleForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _RoleFormDialog(storeId: storeId),
    );
  }
}

class _RoleRow extends ConsumerWidget {
  final EmployeeRole role;
  final String storeId;
  const _RoleRow({required this.role, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(role.name,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          IconButton.ghost(
            icon: const Icon(RadixIcons.pencil1),
            onPressed: () => _showEdit(context),
          ),
          IconButton.ghost(
            icon: Icon(RadixIcons.trash,
                color: theme.colorScheme.destructive),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }

  void _showEdit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _RoleFormDialog(storeId: storeId, role: role),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.common.delete),
        content: Text('${t.common.confirm}?'),
        actions: [
          Button(
            style: const ButtonStyle.outline(),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.common.cancel),
          ),
          Button(
            style: const ButtonStyle.destructive(),
            onPressed: () async {
              final repo = ref.read(employeeRepositoryProvider);
              await repo.deleteRole(role.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                showToast(
                  context: context,
                  builder: (_, overlay) => SurfaceCard(
                      child: Basic(title: Text(t.employees.roleDeleted))),
                );
              }
            },
            child: Text(t.common.delete),
          ),
        ],
      ),
    );
  }
}

class _RoleFormDialog extends ConsumerStatefulWidget {
  final String storeId;
  final EmployeeRole? role;

  const _RoleFormDialog({required this.storeId, this.role});

  @override
  ConsumerState<_RoleFormDialog> createState() => _RoleFormDialogState();
}

class _RoleFormDialogState extends ConsumerState<_RoleFormDialog> {
  late final TextEditingController _nameCtl;
  bool _saving = false;

  bool get _isEdit => widget.role != null;

  @override
  void initState() {
    super.initState();
    _nameCtl = TextEditingController(text: widget.role?.name ?? '');
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return AlertDialog(
      title:
          Text(_isEdit ? t.employees.editRole : t.employees.addRole),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.employees.roleName,
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            TextField(
              controller: _nameCtl,
              placeholder: Text(t.employees.roleName),
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

  Future<void> _save() async {
    final name = _nameCtl.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    final repo = ref.read(employeeRepositoryProvider);
    final t = Translations.of(context);

    if (_isEdit) {
      await repo.updateRole(id: widget.role!.id, name: name);
      if (mounted) {
        showToast(
          context: context,
          builder: (_, overlay) =>
              SurfaceCard(child: Basic(title: Text(t.employees.roleUpdated))),
        );
      }
    } else {
      await repo.createRole(storeId: widget.storeId, name: name);
      if (mounted) {
        showToast(
          context: context,
          builder: (_, overlay) =>
              SurfaceCard(child: Basic(title: Text(t.employees.roleCreated))),
        );
      }
    }

    if (mounted) Navigator.of(context).pop();
  }
}
