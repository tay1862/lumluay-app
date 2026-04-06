import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';
import '../../auth/data/auth_repository.dart';

/// Employee with role name.
class EmployeeWithRole {
  final Employee employee;
  final String? roleName;

  const EmployeeWithRole({required this.employee, this.roleName});
}

class EmployeeRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  EmployeeRepository(this._db);

  // ── Employees ──

  Stream<List<EmployeeWithRole>> watchEmployees(String storeId) {
    final query = _db.select(_db.employees).join([
      leftOuterJoin(_db.employeeRoles,
          _db.employeeRoles.id.equalsExp(_db.employees.roleId)),
    ])
      ..where(_db.employees.storeId.equals(storeId))
      ..orderBy([OrderingTerm.asc(_db.employees.name)]);

    return query.watch().map((rows) => rows.map((row) {
          final emp = row.readTable(_db.employees);
          final role = row.readTableOrNull(_db.employeeRoles);
          return EmployeeWithRole(employee: emp, roleName: role?.name);
        }).toList());
  }

  Future<Result<String>> createEmployee({
    required String storeId,
    required String name,
    String? roleId,
    String? pin,
  }) async {
    try {
      final id = _uuid.v4();
      String? pinHash;
      String? pinSalt;
      if (pin != null && pin.isNotEmpty) {
        pinSalt = AuthRepository.generateSalt();
        pinHash = AuthRepository.hashPin(pin, salt: pinSalt);
      }
      await _db.into(_db.employees).insert(EmployeesCompanion.insert(
            id: id,
            storeId: storeId,
            name: name,
            roleId: Value(roleId),
            pinHash: Value(pinHash),
            pinSalt: Value(pinSalt),
          ));
      return Success(id);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to create employee: $e'));
    }
  }

  Future<Result<void>> updateEmployee({
    required String id,
    required String name,
    String? roleId,
    bool? active,
  }) async {
    try {
      await (_db.update(_db.employees)..where((t) => t.id.equals(id))).write(
        EmployeesCompanion(
          name: Value(name),
          roleId: Value(roleId),
          active: active != null ? Value(active) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to update employee: $e'));
    }
  }

  Future<Result<void>> setPin(String employeeId, String pin) async {
    try {
      final salt = AuthRepository.generateSalt();
      final hash = AuthRepository.hashPin(pin, salt: salt);
      await (_db.update(_db.employees)
            ..where((t) => t.id.equals(employeeId)))
          .write(EmployeesCompanion(pinHash: Value(hash), pinSalt: Value(salt)));
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to set PIN: $e'));
    }
  }

  Future<Result<void>> deleteEmployee(String id) async {
    try {
      await (_db.delete(_db.employees)..where((t) => t.id.equals(id))).go();
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to delete employee: $e'));
    }
  }

  // ── Roles ──

  Stream<List<EmployeeRole>> watchRoles(String storeId) {
    return (_db.select(_db.employeeRoles)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<Result<String>> createRole({
    required String storeId,
    required String name,
    String permissions = '{}',
  }) async {
    try {
      final id = _uuid.v4();
      await _db.into(_db.employeeRoles).insert(EmployeeRolesCompanion.insert(
            id: id,
            storeId: storeId,
            name: name,
            permissions: Value(permissions),
          ));
      return Success(id);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to create role: $e'));
    }
  }

  Future<Result<void>> updateRole({
    required String id,
    required String name,
    String? permissions,
  }) async {
    try {
      await (_db.update(_db.employeeRoles)..where((t) => t.id.equals(id)))
          .write(EmployeeRolesCompanion(
        name: Value(name),
        permissions:
            permissions != null ? Value(permissions) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ));
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to update role: $e'));
    }
  }

  Future<Result<void>> deleteRole(String id) async {
    try {
      await (_db.delete(_db.employeeRoles)..where((t) => t.id.equals(id)))
          .go();
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to delete role: $e'));
    }
  }

  // ── Time Entries ──

  Future<Result<String>> clockIn(String employeeId) async {
    try {
      final id = _uuid.v4();
      await _db.into(_db.timeEntries).insert(TimeEntriesCompanion.insert(
            id: id,
            employeeId: employeeId,
            clockIn: DateTime.now(),
          ));
      return Success(id);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to clock in: $e'));
    }
  }

  Future<Result<void>> clockOut(String employeeId) async {
    try {
      // Find the latest open time entry
      final entry = await (_db.select(_db.timeEntries)
            ..where((t) =>
                t.employeeId.equals(employeeId) & t.clockOut.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.clockIn)])
            ..limit(1))
          .getSingleOrNull();

      if (entry == null) {
        return const Failure(
            DatabaseException(message: 'No open clock-in found'));
      }

      await (_db.update(_db.timeEntries)..where((t) => t.id.equals(entry.id)))
          .write(TimeEntriesCompanion(clockOut: Value(DateTime.now())));
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to clock out: $e'));
    }
  }

  /// Check if an employee is currently clocked in.
  Future<bool> isClockedIn(String employeeId) async {
    final entry = await (_db.select(_db.timeEntries)
          ..where(
              (t) => t.employeeId.equals(employeeId) & t.clockOut.isNull())
          ..limit(1))
        .getSingleOrNull();
    return entry != null;
  }

  /// Watch time entries for an employee (last 30 days).
  Stream<List<TimeEntry>> watchTimeEntries(String employeeId) {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return (_db.select(_db.timeEntries)
          ..where((t) =>
              t.employeeId.equals(employeeId) &
              t.clockIn.isBiggerOrEqualValue(thirtyDaysAgo))
          ..orderBy([(t) => OrderingTerm.desc(t.clockIn)]))
        .watch();
  }

  // ── Helpers ──

}
