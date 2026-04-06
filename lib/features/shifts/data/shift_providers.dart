import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import 'shift_repository.dart';

final shiftRepositoryProvider = Provider<ShiftRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ShiftRepository(db);
});

final currentShiftProvider =
    StreamProvider.family<Shift?, String>((ref, storeId) {
  final repo = ref.watch(shiftRepositoryProvider);
  return repo.watchCurrentShift(storeId);
});

final cashMovementsProvider =
    StreamProvider.family<List<CashMovement>, String>((ref, shiftId) {
  final repo = ref.watch(shiftRepositoryProvider);
  return repo.watchCashMovements(shiftId);
});

final shiftHistoryProvider =
    StreamProvider.family<List<ShiftWithMovements>, String>((ref, storeId) {
  final repo = ref.watch(shiftRepositoryProvider);
  return repo.watchShiftHistory(storeId);
});
