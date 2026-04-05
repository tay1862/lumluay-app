import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../logging/app_logger.dart';

class AuditAction {
  static const String create = 'create';
  static const String update = 'update';
  static const String delete = 'delete';
  static const String login = 'login';
  static const String logout = 'logout';
  static const String refund = 'refund';
  static const String voidReceipt = 'void';
  static const String openShift = 'open_shift';
  static const String closeShift = 'close_shift';
  static const String cashIn = 'cash_in';
  static const String cashOut = 'cash_out';
  static const String priceChange = 'price_change';
  static const String stockAdjust = 'stock_adjust';
  static const String export = 'export';
}

class AuditService {
  final AppDatabase _db;
  static const _uuid = Uuid();

  AuditService(this._db);

  Future<void> log({
    required String storeId,
    String? employeeId,
    required String action,
    required String entityType,
    String? entityId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    String? ipAddress,
  }) async {
    try {
      await _db.into(_db.auditLogs).insert(
            AuditLogsCompanion.insert(
              id: _uuid.v4(),
              storeId: storeId,
              employeeId: Value(employeeId),
              action: action,
              entityType: entityType,
              entityId: Value(entityId),
              oldValues: Value(oldValues?.toString()),
              newValues: Value(newValues?.toString()),
              ipAddress: Value(ipAddress),
            ),
          );
    } catch (e, st) {
      AppLogger.error('Failed to write audit log', e, st);
    }
  }

  Future<List<AuditLog>> getLogsForStore(
    String storeId, {
    int limit = 100,
    int offset = 0,
  }) async {
    return (_db.select(_db.auditLogs)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<List<AuditLog>> getLogsForEntity(
    String entityType,
    String entityId,
  ) async {
    return (_db.select(_db.auditLogs)
          ..where(
              (t) => t.entityType.equals(entityType) & t.entityId.equals(entityId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<List<AuditLog>> getLogsForEmployee(
    String employeeId, {
    int limit = 100,
  }) async {
    return (_db.select(_db.auditLogs)
          ..where((t) => t.employeeId.equals(employeeId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }
}
