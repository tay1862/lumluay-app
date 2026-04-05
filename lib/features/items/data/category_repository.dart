import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';

class CategoryRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  CategoryRepository(this._db);

  Stream<List<Category>> watchCategories(String storeId) {
    return (_db.select(_db.categories)
          ..where((t) => t.storeId.equals(storeId) & t.active.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<List<Category>> getCategories(String storeId) async {
    return (_db.select(_db.categories)
          ..where((t) => t.storeId.equals(storeId) & t.active.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<Category?> getById(String id) async {
    return (_db.select(_db.categories)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<Result<Category>> create({
    required String storeId,
    required String name,
    String color = '#6366F1',
    String icon = 'category',
    int sortOrder = 0,
  }) async {
    try {
      final id = _uuid.v4();
      final companion = CategoriesCompanion.insert(
        id: id,
        storeId: storeId,
        name: name,
        color: Value(color),
        icon: Value(icon),
        sortOrder: Value(sortOrder),
      );
      await _db.into(_db.categories).insert(companion);
      final created = await getById(id);
      return Success(created!);
    } catch (e, st) {
      AppLogger.error('Failed to create category', e, st);
      return Failure(
          DatabaseException(message: 'Failed to create category', originalError: e));
    }
  }

  Future<Result<void>> update({
    required String id,
    String? name,
    String? color,
    String? icon,
    int? sortOrder,
    bool? active,
  }) async {
    try {
      await (_db.update(_db.categories)..where((t) => t.id.equals(id))).write(
        CategoriesCompanion(
          name: name != null ? Value(name) : const Value.absent(),
          color: color != null ? Value(color) : const Value.absent(),
          icon: icon != null ? Value(icon) : const Value.absent(),
          sortOrder:
              sortOrder != null ? Value(sortOrder) : const Value.absent(),
          active: active != null ? Value(active) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to update category', e, st);
      return Failure(
          DatabaseException(message: 'Failed to update category', originalError: e));
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      // Soft delete
      await (_db.update(_db.categories)..where((t) => t.id.equals(id))).write(
        CategoriesCompanion(
          active: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to delete category', e, st);
      return Failure(
          DatabaseException(message: 'Failed to delete category', originalError: e));
    }
  }
}
