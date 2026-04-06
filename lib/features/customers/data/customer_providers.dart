import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/database_provider.dart';
import 'customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CustomerRepository(db);
});

/// Watch all customers for current store.
final customersProvider = StreamProvider<List<Customer>>((ref) {
  final auth = ref.watch(authProvider);
  final repo = ref.watch(customerRepositoryProvider);
  if (auth.currentStoreId == null) return const Stream.empty();
  return repo.watchCustomers(auth.currentStoreId!);
});

/// Search customers.
final customerSearchProvider =
    FutureProvider.family<List<Customer>, String>((ref, query) async {
  final auth = ref.watch(authProvider);
  final repo = ref.watch(customerRepositoryProvider);
  if (auth.currentStoreId == null) return [];
  return repo.searchCustomers(auth.currentStoreId!, query);
});

/// Watch loyalty history for a customer.
final loyaltyHistoryProvider =
    StreamProvider.family<List<LoyaltyTransaction>, String>(
        (ref, customerId) {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.watchLoyaltyHistory(customerId);
});
