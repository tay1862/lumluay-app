import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';

class ModifierRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  ModifierRepository(this._db);

  // ── Modifier Groups ──

  Stream<List<ModifierGroup>> watchGroups(String storeId) {
    return (_db.select(_db.modifierGroups)
          ..where((g) => g.storeId.equals(storeId))
          ..orderBy([(g) => OrderingTerm.asc(g.name)]))
        .watch();
  }

  Future<List<ModifierGroup>> getGroupsForItem(String itemId) async {
    // Join through ItemModifierGroups
    final links = await (_db.select(_db.itemModifierGroups)
          ..where((l) => l.itemId.equals(itemId)))
        .get();
    if (links.isEmpty) return [];
    final groupIds = links.map((l) => l.modifierGroupId).toList();
    return (_db.select(_db.modifierGroups)
          ..where((g) => g.id.isIn(groupIds)))
        .get();
  }

  Future<Result<ModifierGroup>> createGroup({
    required String storeId,
    required String name,
    int minSelect = 0,
    int maxSelect = 0,
  }) async {
    try {
      final id = _uuid.v4();
      await _db
          .into(_db.modifierGroups)
          .insert(ModifierGroupsCompanion.insert(
            id: id,
            storeId: storeId,
            name: name,
            minSelect: Value(minSelect),
            maxSelect: Value(maxSelect),
          ));
      final created = await (_db.select(_db.modifierGroups)
            ..where((g) => g.id.equals(id)))
          .getSingle();
      return Success(created);
    } catch (e, st) {
      AppLogger.error('Failed to create modifier group', e, st);
      return Failure(DatabaseException(message: e.toString()));
    }
  }

  Future<Result<void>> deleteGroup(String groupId) async {
    try {
      await (_db.delete(_db.modifiers)
            ..where((m) => m.modifierGroupId.equals(groupId)))
          .go();
      await (_db.delete(_db.itemModifierGroups)
            ..where((l) => l.modifierGroupId.equals(groupId)))
          .go();
      await (_db.delete(_db.modifierGroups)
            ..where((g) => g.id.equals(groupId)))
          .go();
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to delete modifier group', e, st);
      return Failure(DatabaseException(message: e.toString()));
    }
  }

  // ── Modifiers ──

  Stream<List<Modifier>> watchModifiers(String groupId) {
    return (_db.select(_db.modifiers)
          ..where((m) => m.modifierGroupId.equals(groupId))
          ..orderBy([(m) => OrderingTerm.asc(m.name)]))
        .watch();
  }

  Future<List<Modifier>> getModifiers(String groupId) async {
    return (_db.select(_db.modifiers)
          ..where((m) => m.modifierGroupId.equals(groupId))
          ..orderBy([(m) => OrderingTerm.asc(m.name)]))
        .get();
  }

  Future<Result<Modifier>> createModifier({
    required String modifierGroupId,
    required String name,
    double priceAdjustment = 0.0,
  }) async {
    try {
      final id = _uuid.v4();
      await _db.into(_db.modifiers).insert(ModifiersCompanion.insert(
            id: id,
            modifierGroupId: modifierGroupId,
            name: name,
            priceAdjustment: Value(priceAdjustment),
          ));
      final created =
          await (_db.select(_db.modifiers)..where((m) => m.id.equals(id)))
              .getSingle();
      return Success(created);
    } catch (e, st) {
      AppLogger.error('Failed to create modifier', e, st);
      return Failure(DatabaseException(message: e.toString()));
    }
  }

  Future<Result<void>> deleteModifier(String id) async {
    try {
      await (_db.delete(_db.modifiers)..where((m) => m.id.equals(id))).go();
      return const Success(null);
    } catch (e, st) {
      AppLogger.error('Failed to delete modifier', e, st);
      return Failure(DatabaseException(message: e.toString()));
    }
  }

  // ── Item ↔ Modifier Group Links ──

  Future<void> linkGroupToItem(String itemId, String groupId) async {
    await _db.into(_db.itemModifierGroups).insertOnConflictUpdate(
          ItemModifierGroupsCompanion.insert(
            itemId: itemId,
            modifierGroupId: groupId,
          ),
        );
  }

  Future<void> unlinkGroupFromItem(String itemId, String groupId) async {
    await (_db.delete(_db.itemModifierGroups)
          ..where((l) =>
              l.itemId.equals(itemId) & l.modifierGroupId.equals(groupId)))
        .go();
  }

  Future<List<String>> getLinkedGroupIds(String itemId) async {
    final links = await (_db.select(_db.itemModifierGroups)
          ..where((l) => l.itemId.equals(itemId)))
        .get();
    return links.map((l) => l.modifierGroupId).toList();
  }
}
