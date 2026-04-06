import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';

class ExpenseRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  ExpenseRepository(this._db);

  Stream<List<Expense>> watchExpenses(String storeId) {
    return (_db.select(_db.expenses)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<Result<Expense>> createExpense({
    required String storeId,
    String? categoryId,
    required String description,
    required double amount,
    required DateTime date,
    String? employeeId,
  }) async {
    try {
      final id = _uuid.v4();
      await _db.into(_db.expenses).insert(ExpensesCompanion(
            id: Value(id),
            storeId: Value(storeId),
            categoryId: Value(categoryId),
            description: Value(description),
            amount: Value(amount),
            date: Value(date),
            employeeId: Value(employeeId),
          ));
      final expense = await (_db.select(_db.expenses)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      return Success(expense);
    } catch (e) {
      return Failure(DatabaseException(message: e.toString()));
    }
  }

  Future<Result<void>> deleteExpense(String id) async {
    try {
      await (_db.delete(_db.expenses)..where((t) => t.id.equals(id))).go();
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseException(message: e.toString()));
    }
  }

  // Expense categories
  Stream<List<ExpenseCategory>> watchExpenseCategories(String storeId) {
    return (_db.select(_db.expenseCategories)
          ..where((t) => t.storeId.equals(storeId)))
        .watch();
  }

  Future<Result<ExpenseCategory>> createExpenseCategory({
    required String storeId,
    required String name,
  }) async {
    try {
      final id = _uuid.v4();
      await _db.into(_db.expenseCategories).insert(
            ExpenseCategoriesCompanion(
              id: Value(id),
              storeId: Value(storeId),
              name: Value(name),
            ),
          );
      final cat = await (_db.select(_db.expenseCategories)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      return Success(cat);
    } catch (e) {
      return Failure(DatabaseException(message: e.toString()));
    }
  }
}
