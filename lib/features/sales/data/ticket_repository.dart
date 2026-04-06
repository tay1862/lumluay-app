import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class TicketRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  TicketRepository(this._db);

  // ── Open Tickets ──

  Stream<List<OpenTicket>> watchOpenTickets(String storeId) {
    return (_db.select(_db.openTickets)
          ..where((t) => t.storeId.equals(storeId) & t.status.equals('open'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<List<OpenTicket>> getOpenTickets(String storeId) {
    return (_db.select(_db.openTickets)
          ..where((t) => t.storeId.equals(storeId) & t.status.equals('open'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<OpenTicket> createTicket({
    required String storeId,
    String? employeeId,
    String? customerId,
    String? tableId,
    String ticketName = '',
    String diningOption = 'dine_in',
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.openTickets).insert(OpenTicketsCompanion.insert(
          id: id,
          storeId: storeId,
          employeeId: Value(employeeId),
          customerId: Value(customerId),
          tableId: Value(tableId),
          ticketName: Value(ticketName),
          diningOption: Value(diningOption),
        ));
    return (_db.select(_db.openTickets)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  Future<void> updateTicketTotals(String ticketId) async {
    final items = await getTicketItems(ticketId);
    double subtotal = 0;
    for (final item in items) {
      subtotal += item.total;
    }
    await (_db.update(_db.openTickets)..where((t) => t.id.equals(ticketId)))
        .write(OpenTicketsCompanion(
      subtotal: Value(subtotal),
      total: Value(subtotal),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> closeTicket(String ticketId) async {
    await (_db.update(_db.openTickets)..where((t) => t.id.equals(ticketId)))
        .write(OpenTicketsCompanion(
      status: const Value('closed'),
      updatedAt: Value(DateTime.now()),
    ));
    // Free up the table
    final ticket =
        await (_db.select(_db.openTickets)..where((t) => t.id.equals(ticketId)))
            .getSingle();
    if (ticket.tableId != null) {
      await updateTableStatus(ticket.tableId!, 'available');
    }
  }

  Future<void> deleteTicket(String ticketId) async {
    await (_db.delete(_db.openTicketItems)
          ..where((t) => t.ticketId.equals(ticketId)))
        .go();
    await (_db.delete(_db.openTickets)..where((t) => t.id.equals(ticketId)))
        .go();
  }

  Future<void> assignTicketToTable(
      String ticketId, String? tableId) async {
    // Release old table
    final ticket =
        await (_db.select(_db.openTickets)..where((t) => t.id.equals(ticketId)))
            .getSingle();
    if (ticket.tableId != null) {
      await updateTableStatus(ticket.tableId!, 'available');
    }
    // Assign new
    await (_db.update(_db.openTickets)..where((t) => t.id.equals(ticketId)))
        .write(OpenTicketsCompanion(
      tableId: Value(tableId),
      updatedAt: Value(DateTime.now()),
    ));
    if (tableId != null) {
      await updateTableStatus(tableId, 'occupied');
    }
  }

  // ── Ticket Items ──

  Stream<List<OpenTicketItem>> watchTicketItems(String ticketId) {
    return (_db.select(_db.openTicketItems)
          ..where((t) => t.ticketId.equals(ticketId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<List<OpenTicketItem>> getTicketItems(String ticketId) {
    return (_db.select(_db.openTicketItems)
          ..where((t) => t.ticketId.equals(ticketId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<void> addTicketItem({
    required String ticketId,
    required String itemId,
    String? variantId,
    required String name,
    double quantity = 1,
    required double unitPrice,
    double discount = 0,
    String modifiers = '[]',
    String? notes,
    String? kdsStation,
  }) async {
    final id = _uuid.v4();
    final total = (unitPrice - discount) * quantity;
    await _db.into(_db.openTicketItems).insert(
          OpenTicketItemsCompanion.insert(
            id: id,
            ticketId: ticketId,
            itemId: Value(itemId),
            variantId: Value(variantId),
            name: name,
            quantity: Value(quantity),
            unitPrice: Value(unitPrice),
            discount: Value(discount),
            total: Value(total),
            modifiers: Value(modifiers),
            notes: Value(notes),
            kdsStation: Value(kdsStation),
          ),
        );
    await updateTicketTotals(ticketId);
  }

  Future<void> removeTicketItem(String itemRowId) async {
    final item = await (_db.select(_db.openTicketItems)
          ..where((t) => t.id.equals(itemRowId)))
        .getSingle();
    await (_db.delete(_db.openTicketItems)
          ..where((t) => t.id.equals(itemRowId)))
        .go();
    await updateTicketTotals(item.ticketId);
  }

  Future<void> updateKdsStatus(String itemRowId, String status) async {
    await (_db.update(_db.openTicketItems)
          ..where((t) => t.id.equals(itemRowId)))
        .write(OpenTicketItemsCompanion(kdsStatus: Value(status)));
  }

  // ── Merge tickets ──

  Future<void> mergeTickets(
      String targetTicketId, String sourceTicketId) async {
    // Move all items from source to target
    await (_db.update(_db.openTicketItems)
          ..where((t) => t.ticketId.equals(sourceTicketId)))
        .write(OpenTicketItemsCompanion(ticketId: Value(targetTicketId)));
    await deleteTicket(sourceTicketId);
    await updateTicketTotals(targetTicketId);
  }

  // ── Split: move items from one ticket to a new ticket ──

  Future<OpenTicket> splitTicket({
    required String sourceTicketId,
    required List<String> itemIdsToMove,
    required String storeId,
    String? employeeId,
  }) async {
    final newTicket = await createTicket(
      storeId: storeId,
      employeeId: employeeId,
      ticketName: 'Split',
    );
    for (final itemId in itemIdsToMove) {
      await (_db.update(_db.openTicketItems)
            ..where((t) => t.id.equals(itemId)))
          .write(OpenTicketItemsCompanion(ticketId: Value(newTicket.id)));
    }
    await updateTicketTotals(sourceTicketId);
    await updateTicketTotals(newTicket.id);
    return newTicket;
  }

  // ── Restaurant Tables ──

  Stream<List<RestaurantTable>> watchTables(String storeId) {
    return (_db.select(_db.restaurantTables)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<List<RestaurantTable>> getTables(String storeId) {
    return (_db.select(_db.restaurantTables)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<RestaurantTable> createTable({
    required String storeId,
    required String name,
    int seats = 4,
    String zone = 'main',
    int posX = 0,
    int posY = 0,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.restaurantTables).insert(
          RestaurantTablesCompanion.insert(
            id: id,
            storeId: storeId,
            name: name,
            seats: Value(seats),
            zone: Value(zone),
            posX: Value(posX),
            posY: Value(posY),
          ),
        );
    return (_db.select(_db.restaurantTables)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  Future<void> updateTable(String tableId, {String? name, int? seats, String? zone}) async {
    await (_db.update(_db.restaurantTables)
          ..where((t) => t.id.equals(tableId)))
        .write(RestaurantTablesCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      seats: seats != null ? Value(seats) : const Value.absent(),
      zone: zone != null ? Value(zone) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deleteTable(String tableId) async {
    await (_db.delete(_db.restaurantTables)
          ..where((t) => t.id.equals(tableId)))
        .go();
  }

  Future<void> updateTableStatus(String tableId, String status) async {
    await (_db.update(_db.restaurantTables)
          ..where((t) => t.id.equals(tableId)))
        .write(RestaurantTablesCompanion(
      status: Value(status),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // ── KDS Routing ──

  Future<List<KdsRoutingData>> getKdsRouting(String storeId) {
    return (_db.select(_db.kdsRouting)
          ..where((t) => t.storeId.equals(storeId)))
        .get();
  }

  Future<void> setKdsRoute({
    required String storeId,
    required String categoryId,
    required String station,
  }) async {
    // Upsert: delete existing then insert
    await (_db.delete(_db.kdsRouting)
          ..where((t) =>
              t.storeId.equals(storeId) & t.categoryId.equals(categoryId)))
        .go();
    final id = _uuid.v4();
    await _db.into(_db.kdsRouting).insert(KdsRoutingCompanion.insert(
          id: id,
          storeId: storeId,
          categoryId: categoryId,
          station: Value(station),
        ));
  }

  /// Get KDS station for a given category (for routing items to correct station)
  Future<String> getStationForCategory(
      String storeId, String? categoryId) async {
    if (categoryId == null) return 'kitchen';
    final route = await (_db.select(_db.kdsRouting)
          ..where((t) =>
              t.storeId.equals(storeId) & t.categoryId.equals(categoryId)))
        .getSingleOrNull();
    return route?.station ?? 'kitchen';
  }

  // ── KDS: Watch items by station ──

  Stream<List<OpenTicketItem>> watchKdsItems(
      String storeId, String station) {
    // Get all open ticket IDs for this store, then filter items by station
    final ticketIds = _db.selectOnly(_db.openTickets)
      ..addColumns([_db.openTickets.id])
      ..where(_db.openTickets.storeId.equals(storeId) &
          _db.openTickets.status.equals('open'));

    return (_db.select(_db.openTicketItems)
          ..where((t) =>
              t.ticketId.isInQuery(ticketIds) &
              (t.kdsStation.equals(station) | t.kdsStation.isNull()) &
              t.kdsStatus.isIn(['pending', 'preparing']))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }
}
