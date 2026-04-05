import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../logging/app_logger.dart';

enum SyncStatus { idle, syncing, error }

class SyncService {
  final AppDatabase _db;
  static const _uuid = Uuid();

  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;

  SyncService(this._db);

  Future<void> enqueue({
    required String entityTable,
    required String rowId,
    required String action,
    Map<String, dynamic>? payload,
  }) async {
    try {
      await _db.into(_db.syncQueue).insert(
            SyncQueueCompanion.insert(
              id: _uuid.v4(),
              entityTable: entityTable,
              rowId: rowId,
              action: action,
              payload: Value(payload?.toString() ?? '{}'),
            ),
          );
      AppLogger.debug('Enqueued sync: $action on $entityTable/$rowId');
    } catch (e, st) {
      AppLogger.error('Failed to enqueue sync', e, st);
    }
  }

  Future<int> pendingCount() async {
    final query = _db.selectOnly(_db.syncQueue)
      ..addColumns([_db.syncQueue.id.count()])
      ..where(_db.syncQueue.status.equals('pending'));
    final result = await query.getSingle();
    return result.read(_db.syncQueue.id.count()) ?? 0;
  }

  // TODO: Phase 11 — Implement push/pull sync with Serverpod backend
  Future<void> pushChanges() async {
    _status = SyncStatus.syncing;
    AppLogger.info('Sync push: not yet connected to backend');
    _status = SyncStatus.idle;
  }

  Future<void> pullChanges() async {
    _status = SyncStatus.syncing;
    AppLogger.info('Sync pull: not yet connected to backend');
    _status = SyncStatus.idle;
  }
}
