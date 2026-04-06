import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../i18n/strings.g.dart';
import '../data/items_providers.dart';
import 'category_form_dialog.dart';
import 'csv_import_export_dialog.dart';
import 'item_form_dialog.dart';
import 'label_print_dialog.dart';

class ItemsScreen extends ConsumerStatefulWidget {
  const ItemsScreen({super.key});

  @override
  ConsumerState<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends ConsumerState<ItemsScreen> {
  String? _selectedCategoryId;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final itemsAsync = ref.watch(itemsStreamProvider(_selectedCategoryId));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  t.items.allItems,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Button(
                style: const ButtonStyle.outline(),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => CsvImportExportDialog(storeId: auth.currentStoreId ?? ''),
                ),
                child: const Row(
                  children: [
                    Icon(RadixIcons.download, size: 16),
                    SizedBox(width: 6),
                    Text('CSV'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Button(
                style: const ButtonStyle.outline(),
                onPressed: () {
                  // Batch label print for all visible items
                  final items = ref.read(itemsStreamProvider(_selectedCategoryId)).valueOrNull ?? [];
                  if (items.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (_) => LabelPrintDialog(items: items),
                    );
                  }
                },
                child: const Row(
                  children: [
                    Icon(RadixIcons.reader, size: 16),
                    SizedBox(width: 6),
                    Text('Labels'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Button(
                style: const ButtonStyle.outline(),
                onPressed: () => _showCategoryDialog(context, auth.currentStoreId),
                child: Row(
                  children: [
                    const Icon(RadixIcons.plus, size: 16),
                    const SizedBox(width: 6),
                    Text(t.items.addCategory),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Button(
                style: const ButtonStyle.primary(),
                onPressed: () => _showItemDialog(context, auth.currentStoreId),
                child: Row(
                  children: [
                    const Icon(RadixIcons.plus, size: 16),
                    const SizedBox(width: 6),
                    Text(t.items.addItem),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search bar
          SizedBox(
            width: 320,
            child: TextField(
              placeholder: Text(t.common.search),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const SizedBox(height: 16),

          // Category filter chips
          categoriesAsync.when(
            data: (categories) => _buildCategoryChips(categories, theme, t),
            loading: () => const SizedBox(height: 36),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: 16),

          // Items grid
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                final filtered = _searchQuery.isEmpty
                    ? items
                    : items
                        .where((i) => i.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(RadixIcons.cube, size: 48,
                            color: theme.colorScheme.mutedForeground),
                        const SizedBox(height: 12),
                        Text(t.items.noItems,
                            style: TextStyle(
                                color: theme.colorScheme.mutedForeground)),
                      ],
                    ),
                  );
                }

                return _buildItemsGrid(filtered, theme);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(
      List<Category> categories, ThemeData theme, Translations t) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Button(
              style: _selectedCategoryId == null
                  ? const ButtonStyle.primary(
                      density: ButtonDensity.compact)
                  : const ButtonStyle.outline(
                      density: ButtonDensity.compact),
              onPressed: () =>
                  setState(() => _selectedCategoryId = null),
              child: Text(t.common.all),
            ),
          ),
          ...categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Button(
                  style: _selectedCategoryId == cat.id
                      ? const ButtonStyle.primary(
                          density: ButtonDensity.compact)
                      : const ButtonStyle.outline(
                          density: ButtonDensity.compact),
                  onPressed: () =>
                      setState(() => _selectedCategoryId = cat.id),
                  child: Text(cat.name),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildItemsGrid(List<Item> items, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 600
                ? 3
                : 2;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _ItemCard(
              item: item,
              onTap: () => _showItemDialog(
                context,
                ref.read(authProvider).currentStoreId,
                existingItem: item,
              ),
            );
          },
        );
      },
    );
  }

  void _showCategoryDialog(BuildContext context, String? storeId) {
    if (storeId == null) return;
    showDialog(
      context: context,
      builder: (_) => CategoryFormDialog(storeId: storeId),
    );
  }

  void _showItemDialog(BuildContext context, String? storeId,
      {Item? existingItem}) {
    if (storeId == null) return;
    showDialog(
      context: context,
      builder: (_) => ItemFormDialog(
        storeId: storeId,
        existingItem: existingItem,
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const _ItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Item icon/image placeholder
              Expanded(
                child: Center(
                  child: Icon(
                    RadixIcons.cube,
                    size: 36,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '₭${item.price.toStringAsFixed(0)}',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (item.sku != null && item.sku!.isNotEmpty)
                Text(
                  item.sku!,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
