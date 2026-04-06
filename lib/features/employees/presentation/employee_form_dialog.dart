import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../i18n/strings.g.dart';
import '../data/employee_providers.dart';

class EmployeeFormDialog extends ConsumerStatefulWidget {
  final String storeId;
  final Employee? employee;

  const EmployeeFormDialog({
    super.key,
    required this.storeId,
    this.employee,
  });

  @override
  ConsumerState<EmployeeFormDialog> createState() =>
      _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends ConsumerState<EmployeeFormDialog> {
  late final TextEditingController _nameCtl;
  late final TextEditingController _pinCtl;
  String? _selectedRoleId;
  bool _active = true;
  bool _saving = false;

  bool get _isEdit => widget.employee != null;

  @override
  void initState() {
    super.initState();
    _nameCtl = TextEditingController(text: widget.employee?.name ?? '');
    _pinCtl = TextEditingController();
    _selectedRoleId = widget.employee?.roleId;
    _active = widget.employee?.active ?? true;
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _pinCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final rolesAsync = ref.watch(rolesProvider(widget.storeId));

    return AlertDialog(
      title: Text(_isEdit ? t.employees.editEmployee : t.employees.addEmployee),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name field
            Text(t.employees.employeeName,
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            TextField(
              controller: _nameCtl,
              placeholder: Text(t.employees.employeeName),
            ),
            const SizedBox(height: 12),

            // Role selector
            Text(t.employees.selectRole,
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            rolesAsync.when(
              data: (roles) => Select<String?>(
                value: _selectedRoleId,
                onChanged: (v) => setState(() => _selectedRoleId = v),
                placeholder: Text(t.employees.noRole),
                itemBuilder: (context, item) =>
                    Text(roles.firstWhere((r) => r.id == item).name),
                popup: (_) => SelectPopup(
                  items: SelectItemList(
                    children: [
                      SelectItemButton(
                        value: null,
                        child: Text(t.employees.noRole),
                      ),
                      ...roles.map((r) => SelectItemButton(
                            value: r.id,
                            child: Text(r.name),
                          )),
                    ],
                  ),
                ),
              ),
              loading: () => const SizedBox(
                  height: 36, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: 12),

            // PIN field
            Text(t.employees.enterPin, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            TextField(
              controller: _pinCtl,
              placeholder: Text(t.employees.pinHint),
              obscureText: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
            ),
            if (_isEdit)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _isEdit ? '(leave empty to keep current PIN)' : '',
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.mutedForeground),
                ),
              ),

            const SizedBox(height: 12),

            // Active toggle
            if (_isEdit)
              Row(
                children: [
                  Text(t.common.status, style: const TextStyle(fontSize: 13)),
                  const Spacer(),
                  Switch(
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
                  ),
                  const SizedBox(width: 6),
                  Text(_active ? t.common.active : t.common.inactive),
                ],
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
      await repo.updateEmployee(
        id: widget.employee!.id,
        name: name,
        roleId: _selectedRoleId,
        active: _active,
      );
      // Update PIN if provided
      final pin = _pinCtl.text.trim();
      if (pin.isNotEmpty) {
        await repo.setPin(widget.employee!.id, pin);
      }
      if (mounted) {
        showToast(
          context: context,
          builder: (_, overlay) =>
              SurfaceCard(child: Basic(title: Text(t.employees.employeeUpdated))),
        );
      }
    } else {
      final pin = _pinCtl.text.trim();
      await repo.createEmployee(
        storeId: widget.storeId,
        name: name,
        roleId: _selectedRoleId,
        pin: pin.isNotEmpty ? pin : null,
      );
      if (mounted) {
        showToast(
          context: context,
          builder: (_, overlay) =>
              SurfaceCard(child: Basic(title: Text(t.employees.employeeCreated))),
        );
      }
    }

    if (mounted) Navigator.of(context).pop();
  }
}
