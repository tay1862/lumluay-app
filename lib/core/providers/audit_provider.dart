import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audit/audit_service.dart';
import 'database_provider.dart';

final auditServiceProvider = Provider<AuditService>((ref) {
  final db = ref.watch(databaseProvider);
  return AuditService(db);
});
