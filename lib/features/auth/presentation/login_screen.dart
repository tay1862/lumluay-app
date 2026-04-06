import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../i18n/strings.g.dart';
import '../../employees/data/employee_providers.dart';
import '../../settings/data/settings_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String? _selectedStoreId;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final storesAsync = ref.watch(allStoresStreamProvider);

    return Scaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  RadixIcons.lockOpen1,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  t.auth.selectEmployee,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                storesAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                  data: (stores) {
                    if (stores.isEmpty) {
                      return _InitialSetup(
                        onSetupComplete: (storeId) {
                          setState(() => _selectedStoreId = storeId);
                        },
                      );
                    }

                    final storeId = _selectedStoreId ?? stores.first.id;
                    if (_selectedStoreId == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() => _selectedStoreId = stores.first.id);
                        }
                      });
                    }

                    return Column(
                      children: [
                        if (stores.length > 1) ...[
                          Select<String>(
                            value: storeId,
                            onChanged: (v) =>
                                setState(() => _selectedStoreId = v),
                            itemBuilder: (context, item) => Text(
                              stores
                                  .firstWhere((s) => s.id == item)
                                  .name,
                            ),
                            popup: (_) => SelectPopup(
                              items: SelectItemList(
                                children: stores
                                    .map((s) => SelectItemButton<String>(
                                          value: s.id,
                                          child: Text(s.name),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        _EmployeeGrid(storeId: storeId),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Initial Setup Widget (shown when no stores exist) ──────────
class _InitialSetup extends ConsumerStatefulWidget {
  final ValueChanged<String> onSetupComplete;
  const _InitialSetup({required this.onSetupComplete});

  @override
  ConsumerState<_InitialSetup> createState() => _InitialSetupState();
}

class _InitialSetupState extends ConsumerState<_InitialSetup> {
  final _storeNameController = TextEditingController(text: 'My Store');
  final _employeeNameController = TextEditingController(text: 'Admin');
  final _pinController = TextEditingController(text: '1234');
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _storeNameController.dispose();
    _employeeNameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _createStoreAndEmployee() async {
    final storeName = _storeNameController.text.trim();
    final employeeName = _employeeNameController.text.trim();
    final pin = _pinController.text.trim();

    if (storeName.isEmpty || employeeName.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    if (pin.length < 4) {
      setState(() => _error = 'PIN must be at least 4 digits');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final storeRepo = ref.read(storeRepositoryProvider);
      final employeeRepo = ref.read(employeeRepositoryProvider);

      // Create store
      final store = await storeRepo.createStore(name: storeName);

      // Create employee with PIN
      final result = await employeeRepo.createEmployee(
        storeId: store.id,
        name: employeeName,
        pin: pin,
      );

      result.when(
        success: (_) {
          widget.onSetupComplete(store.id);
        },
        failure: (error) {
          setState(() {
            _error = error.message;
            _loading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Setup failed: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(RadixIcons.rocket, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Quick Setup',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Create your first store and employee to get started.',
                style: TextStyle(
                  color: theme.colorScheme.mutedForeground,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // Store name
              const Text('Store Name',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              TextField(
                controller: _storeNameController,
                placeholder: const Text('e.g. My Coffee Shop'),
              ),
              const SizedBox(height: 16),

              // Employee name
              const Text('Your Name',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              TextField(
                controller: _employeeNameController,
                placeholder: const Text('e.g. Somchai'),
              ),
              const SizedBox(height: 16),

              // PIN
              const Text('Login PIN',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              TextField(
                controller: _pinController,
                placeholder: const Text('4-digit PIN'),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              Text(
                'You will use this PIN to log in.',
                style: TextStyle(
                  color: theme.colorScheme.mutedForeground,
                  fontSize: 12,
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(
                    color: theme.colorScheme.destructive,
                    fontSize: 13,
                  ),
                ),
              ],

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Button(
                  style: const ButtonStyle.primary(),
                  onPressed: _loading ? null : _createStoreAndEmployee,
                  child: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create & Start'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmployeeGrid extends ConsumerWidget {
  final String storeId;
  const _EmployeeGrid({required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final employeesAsync = ref.watch(employeesProvider(storeId));

    return employeesAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
      data: (employees) {
        final active =
            employees.where((e) => e.employee.active).toList();

        if (active.isEmpty) {
          return Text(
            'No active employees.',
            style:
                TextStyle(color: theme.colorScheme.mutedForeground),
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: active.map((ew) {
            final emp = ew.employee;
            return SizedBox(
              width: 120,
              child: Button(
                style: const ButtonStyle.outline(),
                onPressed: () {
                  context.pushNamed(
                    'pin',
                    pathParameters: {
                      'employeeId': emp.id,
                    },
                    extra: {
                      'employeeName': emp.name,
                      'storeId': storeId,
                    },
                  );
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Icon(
                        RadixIcons.person,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        emp.name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      if (ew.roleName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          ew.roleName!,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme
                                .mutedForeground,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
