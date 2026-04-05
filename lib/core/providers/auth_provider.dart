import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_notifier.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/auth_state.dart';
import 'audit_provider.dart';
import 'database_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AuthRepository(db);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final auditService = ref.watch(auditServiceProvider);
  return AuthNotifier(authRepo, auditService);
});
