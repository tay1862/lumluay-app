import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/auth_provider.dart';
import '../data/ticket_providers.dart';

/// Kitchen Display System — real-time order items grouped by ticket
class KdsScreen extends ConsumerStatefulWidget {
  const KdsScreen({super.key});

  @override
  ConsumerState<KdsScreen> createState() => _KdsScreenState();
}

class _KdsScreenState extends ConsumerState<KdsScreen> {
  String _selectedStation = 'kitchen';
  static const _stations = ['kitchen', 'bar', 'dessert'];

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final storeId = auth.currentStoreId ?? '';
    final kdsAsync = ref.watch(kdsItemsStreamProvider(
        (storeId: storeId, station: _selectedStation)));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      child: Column(
        children: [
          // Station tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.border),
              ),
            ),
            child: Row(
              children: [
                const Icon(RadixIcons.timer, size: 20),
                const SizedBox(width: 8),
                const Text('Kitchen Display',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 24),
                ..._stations.map((station) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Button(
                        style: _selectedStation == station
                            ? const ButtonStyle.primary(
                                density: ButtonDensity.compact)
                            : const ButtonStyle.outline(
                                density: ButtonDensity.compact),
                        onPressed: () =>
                            setState(() => _selectedStation = station),
                        child: Text(_stationLabel(station)),
                      ),
                    )),
                const Spacer(),
                // Recall completed
                Button(
                  style: const ButtonStyle.ghost(
                      density: ButtonDensity.compact),
                  onPressed: () => _showRecallDialog(storeId),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(RadixIcons.clock, size: 14),
                      SizedBox(width: 4),
                      Text('Recall'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // KDS cards
          Expanded(
            child: kdsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(RadixIcons.check,
                            size: 48,
                            color: theme.colorScheme.mutedForeground),
                        const SizedBox(height: 12),
                        Text('All caught up!',
                            style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.mutedForeground)),
                      ],
                    ),
                  );
                }

                // Group by ticketId
                final grouped = <String, List<OpenTicketItem>>{};
                for (final item in items) {
                  grouped.putIfAbsent(item.ticketId, () => []).add(item);
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: grouped.entries.map((entry) {
                      return _KdsCard(
                        ticketId: entry.key,
                        items: entry.value,
                        onItemDone: (id) => _markItemDone(id),
                        onAllDone: () =>
                            _markAllDone(entry.value),
                      );
                    }).toList(),
                  ),
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

  String _stationLabel(String station) {
    switch (station) {
      case 'kitchen':
        return 'Kitchen';
      case 'bar':
        return 'Bar';
      case 'dessert':
        return 'Dessert';
      default:
        return station;
    }
  }

  Future<void> _markItemDone(String itemId) async {
    await ref.read(ticketRepositoryProvider).updateKdsStatus(itemId, 'ready');
  }

  Future<void> _markAllDone(List<OpenTicketItem> items) async {
    final repo = ref.read(ticketRepositoryProvider);
    for (final item in items) {
      await repo.updateKdsStatus(item.id, 'ready');
    }
  }

  Future<void> _showRecallDialog(String storeId) async {
    // Simple recall: show recently completed items
    showToast(
      context: context,
      builder: (_, overlay) => SurfaceCard(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Basic(
            title: const Text('Recall'),
            subtitle: const Text('Recently completed orders cleared from view'),
          ),
        ),
      ),
    );
  }
}

// ── KDS Order Card ──

class _KdsCard extends StatelessWidget {
  final String ticketId;
  final List<OpenTicketItem> items;
  final ValueChanged<String> onItemDone;
  final VoidCallback onAllDone;

  const _KdsCard({
    required this.ticketId,
    required this.items,
    required this.onItemDone,
    required this.onAllDone,
  });

  Color _ageColor(DateTime createdAt) {
    final elapsed = DateTime.now().difference(createdAt).inMinutes;
    if (elapsed < 5) return Colors.green;
    if (elapsed < 10) return Colors.yellow.shade700;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final oldest =
        items.map((i) => i.createdAt).reduce((a, b) => a.isBefore(b) ? a : b);
    final elapsed = DateTime.now().difference(oldest).inMinutes;
    final borderColor = _ageColor(oldest);

    return SizedBox(
      width: 260,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: borderColor, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ticket',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    Text('${elapsed}m',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: borderColor,
                            fontSize: 12)),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Items
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: items
                      .map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: GestureDetector(
                              onTap: () => onItemDone(item.id),
                              child: Row(
                                children: [
                                  Icon(
                                    item.kdsStatus == 'preparing'
                                        ? RadixIcons.clock
                                        : RadixIcons.minus,
                                    size: 14,
                                    color: item.kdsStatus == 'preparing'
                                        ? Colors.blue
                                        : theme.colorScheme.mutedForeground,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'x${item.quantity.toInt()} ${item.name}',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        if (item.notes != null &&
                                            item.notes!.isNotEmpty)
                                          Text(item.notes!,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: theme.colorScheme
                                                      .destructive)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              // Actions
              Padding(
                padding: const EdgeInsets.all(8),
                child: Button(
                  style: const ButtonStyle.primary(
                      density: ButtonDensity.compact),
                  onPressed: onAllDone,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(RadixIcons.check, size: 14),
                      SizedBox(width: 4),
                      Text('Done'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
