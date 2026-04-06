import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class SettingsRepository {
  final AppDatabase _db;

  SettingsRepository(this._db);

  Future<String?> getValue(String storeId, String key) async {
    final row = await (_db.select(_db.settings)
          ..where(
              (s) => s.storeId.equals(storeId) & s.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setValue(String storeId, String key, String value) async {
    final existing = await (_db.select(_db.settings)
          ..where(
              (s) => s.storeId.equals(storeId) & s.key.equals(key)))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.settings)
            ..where((s) => s.id.equals(existing.id)))
          .write(SettingsCompanion(
        value: Value(value),
        updatedAt: Value(DateTime.now()),
      ));
    } else {
      await _db.into(_db.settings).insert(SettingsCompanion(
            id: Value('${storeId}_$key'),
            storeId: Value(storeId),
            key: Value(key),
            value: Value(value),
            updatedAt: Value(DateTime.now()),
          ));
    }
  }

  Stream<Map<String, String>> watchAllSettings(String storeId) {
    return (_db.select(_db.settings)
          ..where((s) => s.storeId.equals(storeId)))
        .watch()
        .map((rows) => {for (final r in rows) r.key: r.value});
  }
}
