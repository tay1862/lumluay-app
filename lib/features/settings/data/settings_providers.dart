import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';
import 'settings_repository.dart';
import 'store_repository.dart';
import 'tax_rate_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsRepository(db);
});

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return StoreRepository(db);
});

final taxRateRepositoryProvider = Provider<TaxRateRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TaxRateRepository(db);
});

final taxRatesStreamProvider =
    StreamProvider.family<List<dynamic>, String>((ref, storeId) {
  return ref.watch(taxRateRepositoryProvider).watchTaxRates(storeId);
});

final storeStreamProvider =
    StreamProvider.family<dynamic, String>((ref, storeId) {
  return ref.watch(storeRepositoryProvider).watchStore(storeId);
});

/// Watch all stores
final allStoresStreamProvider = StreamProvider<List<dynamic>>((ref) {
  return ref.watch(storeRepositoryProvider).watchStores();
});
