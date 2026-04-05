import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sync/sync_service.dart';
import 'database_provider.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncService(db);
});
