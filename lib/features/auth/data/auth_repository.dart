import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';

class AuthRepository {
  final AppDatabase _db;

  AuthRepository(this._db);

  // --- Rate limiting ---
  static const _maxAttempts = 5;
  static const _lockoutDuration = Duration(minutes: 5);
  static final _failedAttempts = <String, List<DateTime>>{};

  /// Check if employee is locked out
  static bool isLockedOut(String employeeId) {
    final attempts = _failedAttempts[employeeId];
    if (attempts == null || attempts.length < _maxAttempts) return false;
    final oldest = attempts.first;
    if (DateTime.now().difference(oldest) > _lockoutDuration) {
      _failedAttempts.remove(employeeId);
      return false;
    }
    return true;
  }

  static void _recordFailedAttempt(String employeeId) {
    _failedAttempts.putIfAbsent(employeeId, () => []);
    final list = _failedAttempts[employeeId]!;
    list.add(DateTime.now());
    // Keep only last N attempts
    while (list.length > _maxAttempts) {
      list.removeAt(0);
    }
  }

  static void _clearAttempts(String employeeId) {
    _failedAttempts.remove(employeeId);
  }

  // --- PIN hashing ---
  static final _random = Random.secure();

  /// Generate a random 16-byte salt
  static String generateSalt() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64Encode(bytes);
  }

  /// Hash a PIN with HMAC-SHA256 using a salt
  static String hashPin(String pin, {String? salt}) {
    if (salt != null && salt.isNotEmpty) {
      final key = utf8.encode(salt);
      final hmac = Hmac(sha256, key);
      return hmac.convert(utf8.encode(pin)).toString();
    }
    // Legacy fallback: plain SHA-256 (for migration)
    return sha256.convert(utf8.encode(pin)).toString();
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
      if (isLockedOut(employeeId)) {
        return const Failure(
          AuthException(message: 'Too many attempts. Try again in 5 minutes.'),
        );
      }

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

      final inputHash = hashPin(pin, salt: employee.pinSalt);
      if (inputHash != employee.pinHash) {
        _recordFailedAttempt(employeeId);
        return const Failure(AuthException(message: 'Wrong PIN'));
      }

      _clearAttempts(employeeId);

      // Migrate legacy unsalted hash to salted
      if (employee.pinSalt == null || employee.pinSalt!.isEmpty) {
        await _migratePinToSalted(employeeId, pin);
      }

      return Success(employee);
    } catch (e, st) {
      AppLogger.error('PIN verification failed', e, st);
      return Failure(AuthException(message: 'Authentication failed', originalError: e));
    }
  }

  /// Set or update an employee's PIN (always salted)
  Future<Result<void>> setPin(String employeeId, String newPin) async {
    try {
      final salt = generateSalt();
      final hash = hashPin(newPin, salt: salt);
      await (_db.update(_db.employees)..where((t) => t.id.equals(employeeId)))
          .write(EmployeesCompanion(
        pinHash: Value(hash),
        pinSalt: Value(salt),
      ));
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Set PIN failed', e, st);
      return Failure(AuthException(message: 'Failed to set PIN', originalError: e));
    }
  }

  /// Migrate a legacy SHA-256 hash to salted HMAC-SHA256
  Future<void> _migratePinToSalted(String employeeId, String pin) async {
    try {
      await setPin(employeeId, pin);
      AppLogger.info('Migrated PIN to salted hash for employee $employeeId');
    } catch (e) {
      // Non-fatal — migration will retry on next login
      AppLogger.warning('PIN migration failed for $employeeId: $e');
    }
  }
}
