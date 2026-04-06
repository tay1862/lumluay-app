import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/constants/currency_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/database_provider.dart';
import '../../items/data/items_providers.dart';
import '../../items/presentation/variant_picker_dialog.dart';
import '../../items/presentation/modifier_picker_dialog.dart';
import '../data/sales_providers.dart';
import '../data/ticket_providers.dart';
import '../data/ticket_repository.dart';

/// Open Tickets screen — manage multiple simultaneous restaurant tickets
class OpenTicketsScreen extends ConsumerStatefulWidget {
  const OpenTicketsScreen({super.key});

  @override
  ConsumerState<OpenTicketsScreen> createState() => _OpenTicketsScreenState();
}

class _OpenTicketsScreenState extends ConsumerState<OpenTicketsScreen> {
  String? _selectedTicketId;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final storeId = auth.currentStoreId ?? '';
    final ticketsAsync = ref.watch(openTicketsStreamProvider(storeId));
    final theme = Theme.of(context);

    return Row(
      children: [
        // Left: ticket list
        SizedBox(
          width: 260,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: theme.colorScheme.border),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('Open Tickets',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      Button(
                        style: const ButtonStyle.primary(
                            density: ButtonDensity.compact),
                        onPressed: () => _createTicket(storeId),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(RadixIcons.plus, size: 14),
                            SizedBox(width: 4),
                            Text('New'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ticketsAsync.when(
                    data: (tickets) {
                      if (tickets.isEmpty) {
                        return Center(
                          child: Text('No open tickets',
                              style: TextStyle(
                                  color: theme.colorScheme.mutedForeground)),
                        );
                      }
                      return ListView.builder(
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = tickets[index];
                          final isSelected =
                              ticket.id == _selectedTicketId;
                          return _TicketListTile(
                            ticket: ticket,
                            isSelected: isSelected,
                            onTap: () =>
                                setState(() => _selectedTicketId = ticket.id),
                            onDelete: () => _deleteTicket(ticket.id),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('$e')),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right: ticket detail + items
        Expanded(
          child: _selectedTicketId == null
              ? Center(
                  child: Text('Select or create a ticket',
                      style:
                          TextStyle(color: theme.colorScheme.mutedForeground)),
                )
              : _TicketDetail(
                  ticketId: _selectedTicketId!,
                  onClose: () => setState(() => _selectedTicketId = null),
                ),
        ),
      ],
    );
  }

  Future<void> _createTicket(String storeId) async {
    final auth = ref.read(authProvider);
    final repo = ref.read(ticketRepositoryProvider);
    final tickets = await repo.getOpenTickets(storeId);
    final ticket = await repo.createTicket(
      storeId: storeId,
      employeeId: auth.currentEmployee?.id,
      ticketName: 'Ticket ${tickets.length + 1}',
    );
    setState(() => _selectedTicketId = ticket.id);
  }

  Future<void> _deleteTicket(String ticketId) async {
    final repo = ref.read(ticketRepositoryProvider);
    await repo.deleteTicket(ticketId);
    if (_selectedTicketId == ticketId) {
      setState(() => _selectedTicketId = null);
    }
  }
}

// ── Ticket list tile ──

class _TicketListTile extends StatelessWidget {
  final OpenTicket ticket;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TicketListTile({
    required this.ticket,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.accent : null,
          border: Border(
            bottom: BorderSide(
                color: theme.colorScheme.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.ticketName.isEmpty
                        ? 'Ticket'
                        : ticket.ticketName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (ticket.tableId != null)
                    Text('Table assigned',
                        style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.mutedForeground)),
                  Text(
                    CurrencyService.format(ticket.total, 'LAK'),
                    style: TextStyle(
                        fontSize: 12, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),
            IconButton.ghost(
              icon: const Icon(RadixIcons.trash, size: 14),
              onPressed: onDelete,
              variance: ButtonVariance.ghost,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ticket detail: items + actions ──

class _TicketDetail extends ConsumerStatefulWidget {
  final String ticketId;
  final VoidCallback onClose;

  const _TicketDetail({required this.ticketId, required this.onClose});

  @override
  ConsumerState<_TicketDetail> createState() => _TicketDetailState();
}

class _TicketDetailState extends ConsumerState<_TicketDetail> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemsAsync = ref.watch(ticketItemsStreamProvider(widget.ticketId));
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final catalogAsync = ref.watch(itemsStreamProvider(_selectedCategoryId));
    final tablesAsync = ref.watch(restaurantTablesStreamProvider(
        ref.watch(authProvider).currentStoreId ?? ''));

    return Column(
      children: [
        // Toolbar
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(RadixIcons.reader, size: 18),
              const SizedBox(width: 8),
              const Text('Ticket Detail',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              // Assign to table
              tablesAsync.when(
                data: (tables) {
                  if (tables.isEmpty) return const SizedBox.shrink();
                  return Button(
                    style: const ButtonStyle.outline(
                        density: ButtonDensity.compact),
                    onPressed: () =>
                        _showTableAssign(context, tables),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(RadixIcons.home, size: 14),
                        SizedBox(width: 4),
                        Text('Table'),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(width: 6),
              // Merge
              Button(
                style:
                    const ButtonStyle.outline(density: ButtonDensity.compact),
                onPressed: () => _showMergeDialog(),
                child: const Text('Merge'),
              ),
              const SizedBox(width: 6),
              // Send to POS (load ticket into cart)
              Button(
                style: const ButtonStyle.primary(
                    density: ButtonDensity.compact),
                onPressed: () => _sendToPOS(),
                child: const Text('Charge'),
              ),
            ],
          ),
        ),
        const Divider(),
        // Main body: items panel + catalog
        Expanded(
          child: Row(
            children: [
              // Catalog (add items)
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      categoriesAsync.when(
                        data: (cats) => SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: [
                            _catChip(null, 'All'),
                            ...cats.map((c) => _catChip(c.id, c.name)),
                          ]),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: catalogAsync.when(
                          data: (items) => GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1.3,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return GestureDetector(
                                onTap: () => _addItemToTicket(item),
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(item.name,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center),
                                        const SizedBox(height: 4),
                                        Text(
                                          CurrencyService.format(
                                              item.price, 'LAK'),
                                          style: TextStyle(
                                              fontSize: 11,
                                              color:
                                                  theme.colorScheme.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          loading: () => const Center(
                              child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('$e')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Ticket items panel
              SizedBox(
                width: 300,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: theme.colorScheme.border),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: itemsAsync.when(
                          data: (ticketItems) {
                            if (ticketItems.isEmpty) {
                              return Center(
                                child: Text('Add items',
                                    style: TextStyle(
                                        color: theme
                                            .colorScheme.mutedForeground)),
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: ticketItems.length,
                              itemBuilder: (context, i) {
                                final ti = ticketItems[i];
                                return _TicketItemRow(
                                  item: ti,
                                  onRemove: () => _removeItem(ti.id),
                                  onStatusChange: (s) =>
                                      _updateKdsStatus(ti.id, s),
                                );
                              },
                            );
                          },
                          loading: () => const Center(
                              child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('$e')),
                        ),
                      ),
                      const Divider(),
                      // Ticket total
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: itemsAsync.when(
                          data: (items) {
                            final total = items.fold<double>(
                                0, (s, i) => s + i.total);
                            return Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  CurrencyService.format(total, 'LAK'),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _catChip(String? id, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Button(
        style: _selectedCategoryId == id
            ? const ButtonStyle.primary(density: ButtonDensity.compact)
            : const ButtonStyle.outline(density: ButtonDensity.compact),
        onPressed: () => setState(() => _selectedCategoryId = id),
        child: Text(label, style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  Future<void> _addItemToTicket(Item item) async {
    final repo = ref.read(ticketRepositoryProvider);
    final storeId = ref.read(authProvider).currentStoreId ?? '';

    // Check variants
    final variantGroups =
        await ref.read(variantRepositoryProvider).getGroups(item.id);
    if (variantGroups.isNotEmpty && mounted) {
      showDialog(
        context: context,
        builder: (_) => VariantPickerDialog(
          item: item,
          onSelected: (variant) async {
            await _addItemWithModifiers(item, repo, storeId, variant: variant);
          },
        ),
      );
      return;
    }
    await _addItemWithModifiers(item, repo, storeId);
  }

  Future<void> _addItemWithModifiers(
    Item item,
    TicketRepository repo,
    String storeId, {
    Variant? variant,
  }) async {
    final modGroups =
        await ref.read(modifierRepositoryProvider).getGroupsForItem(item.id);
    if (modGroups.isNotEmpty && mounted) {
      showDialog(
        context: context,
        builder: (_) => ModifierPickerDialog(
          item: item,
          onConfirmed: (modifiers) async {
            final station =
                await repo.getStationForCategory(storeId, item.categoryId);
            final modJson = jsonEncode(
                modifiers.map((m) => {'id': m.id, 'name': m.name, 'price': m.priceAdjustment}).toList());
            final modTotal =
                modifiers.fold<double>(0, (s, m) => s + m.priceAdjustment);
            await repo.addTicketItem(
              ticketId: widget.ticketId,
              itemId: item.id,
              variantId: variant?.id,
              name: variant != null
                  ? '${item.name} (${variant.name})'
                  : item.name,
              unitPrice: (variant?.price ?? item.price) + modTotal,
              kdsStation: station,
              modifiers: modJson,
            );
          },
        ),
      );
      return;
    }
    // No modifiers
    final station =
        await repo.getStationForCategory(storeId, item.categoryId);
    await repo.addTicketItem(
      ticketId: widget.ticketId,
      itemId: item.id,
      variantId: variant?.id,
      name: variant != null
          ? '${item.name} (${variant.name})'
          : item.name,
      unitPrice: variant?.price ?? item.price,
      kdsStation: station,
    );
  }

  Future<void> _removeItem(String itemRowId) async {
    await ref.read(ticketRepositoryProvider).removeTicketItem(itemRowId);
  }

  Future<void> _updateKdsStatus(String itemRowId, String status) async {
    await ref
        .read(ticketRepositoryProvider)
        .updateKdsStatus(itemRowId, status);
  }

  void _showTableAssign(
      BuildContext context, List<RestaurantTable> tables) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Assign Table'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Button(
                style: const ButtonStyle.outline(),
                onPressed: () {
                  ref
                      .read(ticketRepositoryProvider)
                      .assignTicketToTable(widget.ticketId, null);
                  Navigator.of(context).pop();
                },
                child: const Text('No Table'),
              ),
              const SizedBox(height: 8),
              ...tables.map((table) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Button(
                      style: table.status == 'available'
                          ? const ButtonStyle.outline()
                          : const ButtonStyle.ghost(),
                      onPressed: table.status == 'available'
                          ? () {
                              ref
                                  .read(ticketRepositoryProvider)
                                  .assignTicketToTable(
                                      widget.ticketId, table.id);
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: Row(
                        children: [
                          Text(table.name),
                          const Spacer(),
                          Text('${table.seats} seats',
                              style: const TextStyle(fontSize: 11)),
                          if (table.status != 'available') ...[
                            const SizedBox(width: 8),
                            Text(table.status,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .destructive)),
                          ],
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMergeDialog() async {
    final storeId = ref.read(authProvider).currentStoreId ?? '';
    final repo = ref.read(ticketRepositoryProvider);
    final tickets = await repo.getOpenTickets(storeId);
    final others =
        tickets.where((t) => t.id != widget.ticketId).toList();
    if (others.isEmpty || !mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Merge Into This Ticket'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: others
                .map((t) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Button(
                        style: const ButtonStyle.outline(),
                        onPressed: () {
                          repo.mergeTickets(widget.ticketId, t.id);
                          Navigator.of(context).pop();
                        },
                        child: Text(t.ticketName.isEmpty
                            ? 'Ticket'
                            : t.ticketName),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  /// Send ticket items to the main POS cart for payment
  Future<void> _sendToPOS() async {
    final repo = ref.read(ticketRepositoryProvider);
    final items = await repo.getTicketItems(widget.ticketId);
    if (items.isEmpty) return;

    final cartNotifier = ref.read(cartProvider.notifier);
    cartNotifier.clear();

    // Load each ticket item into the cart
    for (final ti in items) {
      // Get the actual item from the database
      final db = ref.read(databaseProvider);
      final item = await (db.select(db.items)
            ..where((t) => t.id.equals(ti.itemId ?? '')))
          .getSingleOrNull();
      if (item == null) continue;

      Variant? variant;
      if (ti.variantId != null) {
        variant = await (db.select(db.variants)
              ..where((t) => t.id.equals(ti.variantId!)))
            .getSingleOrNull();
      }

      // Parse modifiers
      List<Modifier> modifiers = [];
      try {
        final modList = jsonDecode(ti.modifiers) as List;
        for (final m in modList) {
          final mod = await (db.select(db.modifiers)
                ..where((t) => t.id.equals(m['id'] as String)))
              .getSingleOrNull();
          if (mod != null) modifiers.add(mod);
        }
      } catch (_) {}

      cartNotifier.addItem(
        item,
        variant: variant,
        modifiers: modifiers,
        quantity: ti.quantity.toInt(),
        overridePrice: ti.unitPrice,
      );
    }

    // Close the ticket
    await repo.closeTicket(widget.ticketId);

    if (mounted) {
      widget.onClose();
      showToast(
        context: context,
        builder: (_, overlay) => SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Basic(
              title: const Text('Ticket sent to POS'),
              subtitle: const Text('Process payment from Sales screen'),
            ),
          ),
        ),
      );
    }
  }
}

// ── Ticket item row ──

class _TicketItemRow extends StatelessWidget {
  final OpenTicketItem item;
  final VoidCallback onRemove;
  final ValueChanged<String> onStatusChange;

  const _TicketItemRow({
    required this.item,
    required this.onRemove,
    required this.onStatusChange,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'served':
        return Colors.gray;
      default:
        return Colors.gray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // KDS status dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _statusColor(item.kdsStatus),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    Text('x${item.quantity.toInt()}',
                        style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.mutedForeground)),
                    const SizedBox(width: 8),
                    Text(item.kdsStatus,
                        style: TextStyle(
                            fontSize: 10,
                            color: _statusColor(item.kdsStatus))),
                  ],
                ),
              ],
            ),
          ),
          Text(CurrencyService.format(item.total, 'LAK'),
              style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          IconButton.ghost(
            icon: const Icon(RadixIcons.cross2, size: 12),
            onPressed: onRemove,
            variance: ButtonVariance.ghost,
          ),
        ],
      ),
    );
  }
}
