import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import 'employee_repository.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return EmployeeRepository(db);
});

final employeesProvider =
    StreamProvider.family<List<EmployeeWithRole>, String>((ref, storeId) {
  final repo = ref.watch(employeeRepositoryProvider);
  return repo.watchEmployees(storeId);
});

final rolesProvider =
    StreamProvider.family<List<EmployeeRole>, String>((ref, storeId) {
  final repo = ref.watch(employeeRepositoryProvider);
  return repo.watchRoles(storeId);
});

final timeEntriesProvider =
    StreamProvider.family<List<TimeEntry>, String>((ref, employeeId) {
  final repo = ref.watch(employeeRepositoryProvider);
  return repo.watchTimeEntries(employeeId);
});
