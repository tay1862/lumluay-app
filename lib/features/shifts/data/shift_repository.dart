import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';

class ShiftWithMovements {
  final Shift shift;
  final String? employeeName;
  final List<CashMovement> movements;

  const ShiftWithMovements({
    required this.shift,
    this.employeeName,
    this.movements = const [],
  });

  double get totalCashIn =>
      movements.where((m) => m.type == 'in').fold(0, (s, m) => s + m.amount);

  double get totalCashOut =>
      movements.where((m) => m.type == 'out').fold(0, (s, m) => s + m.amount);
}

class ShiftRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  ShiftRepository(this._db);

  // ── Current Shift ──

  /// Watch the current open shift for a store.
  Stream<Shift?> watchCurrentShift(String storeId) {
    return (_db.select(_db.shifts)
          ..where(
              (t) => t.storeId.equals(storeId) & t.closedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.openedAt)])
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Open a new shift.
  Future<Result<String>> openShift({
    required String storeId,
    required String employeeId,
    double openingCash = 0,
  }) async {
    try {
      // Check no open shift already exists
      final existing = await (_db.select(_db.shifts)
            ..where(
                (t) => t.storeId.equals(storeId) & t.closedAt.isNull())
            ..limit(1))
          .getSingleOrNull();

      if (existing != null) {
        return const Failure(
            DatabaseException(message: 'A shift is already open'));
      }

      final id = _uuid.v4();
      await _db.into(_db.shifts).insert(ShiftsCompanion.insert(
            id: id,
            storeId: storeId,
            employeeId: employeeId,
            openingCash: Value(openingCash),
          ));
      return Success(id);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to open shift: $e'));
    }
  }

  /// Close the current shift.
  Future<Result<void>> closeShift({
    required String shiftId,
    required double closingCash,
  }) async {
    try {
      // Calculate expected cash
      final shift = await (_db.select(_db.shifts)
            ..where((t) => t.id.equals(shiftId)))
          .getSingle();

      final cashSales = await _getCashSalesForShift(shift);
      final movements = await _getCashMovements(shiftId);
      final totalIn =
          movements.where((m) => m.type == 'in').fold(0.0, (s, m) => s + m.amount);
      final totalOut =
          movements.where((m) => m.type == 'out').fold(0.0, (s, m) => s + m.amount);

      final expectedCash =
          shift.openingCash + cashSales + totalIn - totalOut;

      await (_db.update(_db.shifts)..where((t) => t.id.equals(shiftId)))
          .write(ShiftsCompanion(
        closedAt: Value(DateTime.now()),
        closingCash: Value(closingCash),
        expectedCash: Value(expectedCash),
        updatedAt: Value(DateTime.now()),
      ));
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to close shift: $e'));
    }
  }

  // ── Cash Movements ──

  Stream<List<CashMovement>> watchCashMovements(String shiftId) {
    return (_db.select(_db.cashMovements)
          ..where((t) => t.shiftId.equals(shiftId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<Result<String>> addCashMovement({
    required String shiftId,
    required String type,
    required double amount,
    String reason = '',
  }) async {
    try {
      final id = _uuid.v4();
      await _db.into(_db.cashMovements).insert(
            CashMovementsCompanion.insert(
              id: id,
              shiftId: shiftId,
              type: type,
              amount: amount,
              reason: Value(reason),
            ),
          );
      return Success(id);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to add cash movement: $e'));
    }
  }

  // ── Shift History ──

  Stream<List<ShiftWithMovements>> watchShiftHistory(String storeId) {
    final query = _db.select(_db.shifts).join([
      leftOuterJoin(_db.employees,
          _db.employees.id.equalsExp(_db.shifts.employeeId)),
    ])
      ..where(_db.shifts.storeId.equals(storeId))
      ..orderBy([OrderingTerm.desc(_db.shifts.openedAt)])
      ..limit(50);

    return query.watch().asyncMap((rows) async {
      final shifts = <ShiftWithMovements>[];
      for (final row in rows) {
        final shift = row.readTable(_db.shifts);
        final emp = row.readTableOrNull(_db.employees);
        final movements = await _getCashMovements(shift.id);
        shifts.add(ShiftWithMovements(
          shift: shift,
          employeeName: emp?.name,
          movements: movements,
        ));
      }
      return shifts;
    });
  }

  // ── Helpers ──

  Future<double> _getCashSalesForShift(Shift shift) async {
    // Sum cash payments created during the shift period
    final query = _db.select(_db.payments).join([
      innerJoin(
          _db.receipts, _db.receipts.id.equalsExp(_db.payments.receiptId)),
    ])
      ..where(_db.payments.method.equals('cash') &
          _db.receipts.storeId.equals(shift.storeId) &
          _db.payments.createdAt.isBiggerOrEqualValue(shift.openedAt));

    if (shift.closedAt != null) {
      query.where(
          _db.payments.createdAt.isSmallerOrEqualValue(shift.closedAt!));
    }

    final rows = await query.get();
    double total = 0;
    for (final row in rows) {
      final payment = row.readTable(_db.payments);
      total += payment.amount;
    }
    return total;
  }

  Future<List<CashMovement>> _getCashMovements(String shiftId) async {
    return (_db.select(_db.cashMovements)
          ..where((t) => t.shiftId.equals(shiftId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }
}
