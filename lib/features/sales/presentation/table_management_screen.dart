import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/auth_provider.dart';
import '../data/ticket_providers.dart';

/// Table management screen — floor plan, CRUD, status overview
class TableManagementScreen extends ConsumerStatefulWidget {
  const TableManagementScreen({super.key});

  @override
  ConsumerState<TableManagementScreen> createState() =>
      _TableManagementScreenState();
}

class _TableManagementScreenState
    extends ConsumerState<TableManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final storeId = auth.currentStoreId ?? '';
    final tablesAsync = ref.watch(restaurantTablesStreamProvider(storeId));
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Table Management',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Button(
                style:
                    const ButtonStyle.primary(density: ButtonDensity.compact),
                onPressed: () => _showAddTableDialog(storeId),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(RadixIcons.plus, size: 14),
                    SizedBox(width: 4),
                    Text('Add Table'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            children: [
              _legendDot(Colors.green, 'Available'),
              const SizedBox(width: 16),
              _legendDot(Colors.red, 'Occupied'),
              const SizedBox(width: 16),
              _legendDot(Colors.orange, 'Reserved'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: tablesAsync.when(
              data: (tables) {
                if (tables.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(RadixIcons.home,
                            size: 48,
                            color: theme.colorScheme.mutedForeground),
                        const SizedBox(height: 12),
                        Text('No tables yet',
                            style: TextStyle(
                                color: theme.colorScheme.mutedForeground)),
                        const SizedBox(height: 8),
                        Button(
                          style: const ButtonStyle.outline(),
                          onPressed: () => _showAddTableDialog(storeId),
                          child: const Text('Add First Table'),
                        ),
                      ],
                    ),
                  );
                }
                // Group by zone
                final zones = <String, List<RestaurantTable>>{};
                for (final t in tables) {
                  zones.putIfAbsent(t.zone, () => []).add(t);
                }
                return ListView(
                  children: zones.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            entry.key.toUpperCase(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.mutedForeground,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: entry.value
                              .map((table) => _TableCard(
                                    table: table,
                                    onTap: () => _showTableActions(table),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showAddTableDialog(String storeId) {
    final nameCtrl = TextEditingController();
    final seatsCtrl = TextEditingController(text: '4');
    final zoneCtrl = TextEditingController(text: 'main');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Table'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                placeholder: const Text('Table name (e.g. T1)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: seatsCtrl,
                placeholder: const Text('Seats'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: zoneCtrl,
                placeholder: const Text('Zone (e.g. main, patio)'),
              ),
            ],
          ),
        ),
        actions: [
          Button(
            style: const ButtonStyle.ghost(),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          Button(
            style: const ButtonStyle.primary(),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              await ref.read(ticketRepositoryProvider).createTable(
                    storeId: storeId,
                    name: name,
                    seats: int.tryParse(seatsCtrl.text) ?? 4,
                    zone: zoneCtrl.text.trim().isEmpty
                        ? 'main'
                        : zoneCtrl.text.trim(),
                  );
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showTableActions(RestaurantTable table) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(table.name),
        content: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  '${table.seats} seats • Zone: ${table.zone} • ${table.status}'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Button(
                      style: const ButtonStyle.outline(),
                      onPressed: () {
                        ref
                            .read(ticketRepositoryProvider)
                            .updateTableStatus(table.id, 'available');
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Available'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Button(
                      style: const ButtonStyle.outline(),
                      onPressed: () {
                        ref
                            .read(ticketRepositoryProvider)
                            .updateTableStatus(table.id, 'reserved');
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Reserve'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Button(
                      style: const ButtonStyle.outline(),
                      onPressed: () {
                        _showEditTableDialog(table);
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Button(
                      style: const ButtonStyle.destructive(),
                      onPressed: () {
                        ref
                            .read(ticketRepositoryProvider)
                            .deleteTable(table.id);
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTableDialog(RestaurantTable table) {
    final nameCtrl = TextEditingController(text: table.name);
    final seatsCtrl =
        TextEditingController(text: table.seats.toString());
    final zoneCtrl = TextEditingController(text: table.zone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Table'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                placeholder: const Text('Table name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: seatsCtrl,
                placeholder: const Text('Seats'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: zoneCtrl,
                placeholder: const Text('Zone'),
              ),
            ],
          ),
        ),
        actions: [
          Button(
            style: const ButtonStyle.ghost(),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          Button(
            style: const ButtonStyle.primary(),
            onPressed: () async {
              await ref.read(ticketRepositoryProvider).updateTable(
                    table.id,
                    name: nameCtrl.text.trim().isEmpty
                        ? null
                        : nameCtrl.text.trim(),
                    seats: int.tryParse(seatsCtrl.text),
                    zone: zoneCtrl.text.trim().isEmpty
                        ? null
                        : zoneCtrl.text.trim(),
                  );
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ── Table card for floor plan ──

class _TableCard extends StatelessWidget {
  final RestaurantTable table;
  final VoidCallback onTap;

  const _TableCard({required this.table, required this.onTap});

  Color _statusColor() {
    switch (table.status) {
      case 'occupied':
        return Colors.red;
      case 'reserved':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        height: 100,
        child: Card(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: _statusColor(), width: 3),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(table.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${table.seats} seats',
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.mutedForeground)),
                const SizedBox(height: 2),
                Text(table.status,
                    style: TextStyle(
                        fontSize: 10, color: _statusColor())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
