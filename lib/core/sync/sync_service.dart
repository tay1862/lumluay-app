import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
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

  /// Server base URL — set via environment or settings.
  String? _serverUrl;
  String? _storeId;
  Timer? _syncTimer;

  SyncService(this._db);

  /// Configure the sync service with server URL and store ID.
  void configure({required String serverUrl, required String storeId}) {
    _serverUrl = serverUrl;
    _storeId = storeId;
    AppLogger.info('SyncService configured: $serverUrl for store $storeId');
  }

  /// Start periodic sync (every 5 minutes).
  void startPeriodicSync({Duration interval = const Duration(minutes: 5)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) => syncAll());
    AppLogger.info('Periodic sync started (interval: ${interval.inMinutes}min)');
  }

  /// Stop periodic sync.
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Enqueue a change to the sync queue.
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
              payload: Value(payload != null ? jsonEncode(payload) : '{}'),
            ),
          );
      AppLogger.debug('Enqueued sync: $action on $entityTable/$rowId');
    } catch (e, st) {
      AppLogger.error('Failed to enqueue sync', e, st);
    }
  }

  /// Get count of pending sync operations.
  Future<int> pendingCount() async {
    final query = _db.selectOnly(_db.syncQueue)
      ..addColumns([_db.syncQueue.id.count()])
      ..where(_db.syncQueue.status.equals('pending'));
    final result = await query.getSingle();
    return result.read(_db.syncQueue.id.count()) ?? 0;
  }

  /// Run full sync cycle: push local changes, then pull server changes.
  Future<void> syncAll() async {
    if (_status == SyncStatus.syncing) return;
    if (_serverUrl == null || _storeId == null) {
      AppLogger.debug('SyncService not configured, skipping sync');
      return;
    }

    // Check connectivity
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      AppLogger.debug('No network, skipping sync');
      return;
    }

    try {
      _status = SyncStatus.syncing;
      await pushChanges();
      await pullChanges();
      _status = SyncStatus.idle;
      AppLogger.info('Sync cycle completed');
    } catch (e, st) {
      _status = SyncStatus.error;
      AppLogger.error('Sync cycle failed', e, st);
    }
  }

  /// Push local changes from sync queue to server.
  Future<void> pushChanges() async {
    _status = SyncStatus.syncing;

    try {
      // Get pending records from sync queue
      final pendingRecords = await (_db.select(_db.syncQueue)
            ..where((t) => t.status.equals('pending'))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
            ..limit(100))
          .get();

      if (pendingRecords.isEmpty) {
        AppLogger.debug('No pending sync records');
        _status = SyncStatus.idle;
        return;
      }

      AppLogger.info('Pushing ${pendingRecords.length} sync records');

      // Process each record
      for (final record in pendingRecords) {
        try {
          // TODO: Send to Serverpod client when integrated
          // await _client.sync.push(SyncRequest(
          //   storeId: _storeId!,
          //   records: [SyncRecord(...)],
          //   clientTimestamp: DateTime.now(),
          // ));

          // Mark as success
          await (_db.update(_db.syncQueue)
                ..where((t) => t.id.equals(record.id)))
              .write(const SyncQueueCompanion(status: Value('success')));
        } catch (e) {
          // Increment retry count
          await (_db.update(_db.syncQueue)
                ..where((t) => t.id.equals(record.id)))
              .write(SyncQueueCompanion(
            retryCount: Value(record.retryCount + 1),
            status: Value(record.retryCount >= 5 ? 'failed' : 'pending'),
          ));
          AppLogger.error('Failed to push ${record.entityTable}/${record.rowId}', e);
        }
      }

      // Clean up successful records older than 7 days
      final cutoff = DateTime.now().subtract(const Duration(days: 7));
      await (_db.delete(_db.syncQueue)
            ..where((t) =>
                t.status.equals('success') & t.createdAt.isSmallerThanValue(cutoff)))
          .go();

      _status = SyncStatus.idle;
    } catch (e, st) {
      _status = SyncStatus.error;
      AppLogger.error('Push sync failed', e, st);
    }
  }

  /// Pull server changes since last sync.
  Future<void> pullChanges() async {
    _status = SyncStatus.syncing;

    try {
      // Get last sync timestamp
      final lastSync = await (_db.select(_db.syncLog)
            ..where((t) => t.direction.equals('pull'))
            ..orderBy([(t) => OrderingTerm.desc(t.lastSyncAt)])
            ..limit(1))
          .getSingleOrNull();

      final since = lastSync?.lastSyncAt ?? DateTime(2020);

      AppLogger.info('Pulling changes since $since');

      // TODO: Call Serverpod client when integrated
      // final response = await _client.sync.pull(_storeId!, since);
      // for (final record in response.records) {
      //   await _applyServerRecord(record);
      // }

      // Record sync log
      await _db.into(_db.syncLog).insert(
            SyncLogCompanion.insert(
              id: _uuid.v4(),
              lastSyncAt: DateTime.now().toUtc(),
              direction: 'pull',
              recordsSynced: Value(0), // Update with actual count
            ),
          );

      _status = SyncStatus.idle;
    } catch (e, st) {
      _status = SyncStatus.error;
      AppLogger.error('Pull sync failed', e, st);
    }
  }

  /// Dispose sync service resources.
  void dispose() {
    stopPeriodicSync();
  }
}
