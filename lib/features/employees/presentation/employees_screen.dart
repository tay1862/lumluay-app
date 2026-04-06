import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../i18n/strings.g.dart';
import '../data/employee_providers.dart';
import '../data/employee_repository.dart';
import 'employee_form_dialog.dart';
import 'role_dialog.dart';
import 'time_clock_dialog.dart';

class EmployeesScreen extends ConsumerWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final auth = ref.watch(authProvider);
    final storeId = auth.currentStoreId ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(t.employees.allEmployees,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              Button(
                style: const ButtonStyle.outline(),
                onPressed: () => _showRoles(context, storeId),
                leading: const Icon(RadixIcons.idCard),
                child: Text(t.employees.role),
              ),
              const SizedBox(width: 8),
              Button(
                style: const ButtonStyle.primary(),
                onPressed: () => _showAddEmployee(context, storeId),
                leading: const Icon(RadixIcons.plus),
                child: Text(t.employees.addEmployee),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _EmployeeList(storeId: storeId)),
        ],
      ),
    );
  }

  void _showAddEmployee(BuildContext context, String storeId) {
    showDialog(
      context: context,
      builder: (_) => EmployeeFormDialog(storeId: storeId),
    );
  }

  void _showRoles(BuildContext context, String storeId) {
    showDialog(
      context: context,
      builder: (_) => RoleDialog(storeId: storeId),
    );
  }
}

class _EmployeeList extends ConsumerWidget {
  final String storeId;
  const _EmployeeList({required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final empAsync = ref.watch(employeesProvider(storeId));

    return empAsync.when(
      data: (employees) {
        if (employees.isEmpty) {
          return Center(
            child: Text(t.common.noData,
                style: TextStyle(color: theme.colorScheme.mutedForeground)),
          );
        }
        return ListView.separated(
          itemCount: employees.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (_, index) =>
              _EmployeeRow(emp: employees[index], storeId: storeId),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

class _EmployeeRow extends ConsumerWidget {
  final EmployeeWithRole emp;
  final String storeId;
  const _EmployeeRow({required this.emp, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final employee = emp.employee;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: employee.active ? Colors.green : theme.colorScheme.muted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  emp.roleName ?? '—',
                  style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.mutedForeground),
                ),
              ],
            ),
          ),
          Button(
            style: const ButtonStyle.outline(density: ButtonDensity.compact),
            onPressed: () => _showTimeClock(context, employee),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(RadixIcons.clock, size: 14),
                const SizedBox(width: 4),
                Text(t.employees.timeTracking),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
      builder: (_) => EmployeeFormDialog(
        storeId: storeId,
        employee: emp.employee,
      ),
    );
  }

  void _showTimeClock(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (_) => TimeClockDialog(employee: employee),
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
              await repo.deleteEmployee(emp.employee.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(t.common.delete),
          ),
        ],
      ),
    );
  }
}
