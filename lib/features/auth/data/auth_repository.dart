import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';

class AuthRepository {
  final AppDatabase _db;

  AuthRepository(this._db);

  /// Hash a PIN using SHA-256
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  /// Get all active employees for a store (for the employee picker)
  Future<List<Employee>> getActiveEmployees(String storeId) async {
    return (_db.select(_db.employees)
          ..where((t) => t.storeId.equals(storeId) & t.active.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Verify an employee's PIN
  Future<Result<Employee>> verifyPin(String employeeId, String pin) async {
    try {
      final employee = await (_db.select(_db.employees)
            ..where((t) => t.id.equals(employeeId)))
          .getSingleOrNull();

      if (employee == null) {
        return const Failure(AuthException(message: 'Employee not found'));
      }

      if (!employee.active) {
        return const Failure(AuthException(message: 'Employee is inactive'));
      }

      if (employee.pinHash == null || employee.pinHash!.isEmpty) {
        // No PIN set — allow login (first-time setup)
        return Success(employee);
      }

      final inputHash = hashPin(pin);
      if (inputHash != employee.pinHash) {
        return const Failure(AuthException(message: 'Wrong PIN'));
      }

      return Success(employee);
    } catch (e, st) {
      AppLogger.error('PIN verification failed', e, st);
      return Failure(AuthException(message: 'Authentication failed', originalError: e));
    }
  }

  /// Set or update an employee's PIN
  Future<Result<void>> setPin(String employeeId, String newPin) async {
    try {
      final hash = hashPin(newPin);
      await (_db.update(_db.employees)..where((t) => t.id.equals(employeeId)))
          .write(EmployeesCompanion(pinHash: Value(hash)));
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Set PIN failed', e, st);
      return Failure(AuthException(message: 'Failed to set PIN', originalError: e));
    }
  }
}
