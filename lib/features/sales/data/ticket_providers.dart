import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import 'ticket_repository.dart';

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TicketRepository(db);
});

/// Open tickets for a store (reactive)
final openTicketsStreamProvider =
    StreamProvider.family<List<OpenTicket>, String>((ref, storeId) {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.watchOpenTickets(storeId);
});

/// Items for a specific ticket (reactive)
final ticketItemsStreamProvider =
    StreamProvider.family<List<OpenTicketItem>, String>((ref, ticketId) {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.watchTicketItems(ticketId);
});

/// Restaurant tables for a store (reactive)
final restaurantTablesStreamProvider =
    StreamProvider.family<List<RestaurantTable>, String>((ref, storeId) {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.watchTables(storeId);
});

/// KDS items for a station (reactive)
final kdsItemsStreamProvider =
    StreamProvider.family<List<OpenTicketItem>, ({String storeId, String station})>(
        (ref, params) {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.watchKdsItems(params.storeId, params.station);
});
