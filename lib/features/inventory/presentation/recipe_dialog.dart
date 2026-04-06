import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../i18n/strings.g.dart';
import '../../items/data/items_providers.dart';
import '../data/inventory_providers.dart';


class RecipeDialog extends ConsumerStatefulWidget {
  final String storeId;
  final String? recipeId;

  const RecipeDialog({super.key, required this.storeId, this.recipeId});

  @override
  ConsumerState<RecipeDialog> createState() => _RecipeDialogState();
}

class _RecipeDialogState extends ConsumerState<RecipeDialog> {
  Item? _finishedItem;
  final _outputQtyController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  final List<_IngredientEntry> _ingredients = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.recipeId != null) {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    final repo = ref.read(productionRepositoryProvider);
    final recipe = await repo.getRecipe(widget.recipeId!);
    if (recipe == null) return;

    _outputQtyController.text = recipe.outputQuantity.toString();
    _notesController.text = recipe.notes;

    // Load finished item
    final db = ref.read(databaseProvider);
    final item = await (db.select(db.items)
          ..where((t) => t.id.equals(recipe.finishedItemId)))
        .getSingleOrNull();

    // Load ingredients
    final ingItems = await (db.select(db.recipeItems)
          ..where((t) => t.recipeId.equals(widget.recipeId!)))
        .get();

    final entries = <_IngredientEntry>[];
    for (final ri in ingItems) {
      final ingItem = await (db.select(db.items)
            ..where((t) => t.id.equals(ri.ingredientItemId)))
          .getSingleOrNull();
      if (ingItem != null) {
        entries.add(_IngredientEntry(
          item: ingItem,
          qtyController: TextEditingController(text: ri.quantity.toString()),
        ));
      }
    }

    if (mounted) {
      setState(() {
        _finishedItem = item;
        _ingredients.addAll(entries);
      });
    }
  }

  @override
  void dispose() {
    _outputQtyController.dispose();
    _notesController.dispose();
    for (final e in _ingredients) {
      e.qtyController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isEdit = widget.recipeId != null;

    return AlertDialog(
      title: Text(isEdit ? t.production.editRecipe : t.production.addRecipe),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Finished item selector
              Text(t.production.finishedItem,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _ItemSelector(
                selectedItem: _finishedItem,
                onSelected: (item) => setState(() => _finishedItem = item),
                label: t.production.selectFinishedItem,
              ),
              const SizedBox(height: 16),

              // Output quantity
              Text(t.production.outputQuantity,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _outputQtyController,
                  placeholder: const Text('1'),
                ),
              ),
              const SizedBox(height: 16),

              // Ingredients section
              Row(
                children: [
                  Text(t.production.ingredients,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Button(
                    style: const ButtonStyle.outline(
                        density: ButtonDensity.compact),
                    onPressed: _addIngredient,
                    leading: const Icon(RadixIcons.plus, size: 12),
                    child: Text(t.production.addIngredient),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._ingredients.asMap().entries.map((entry) {
                final idx = entry.key;
                final ing = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ItemSelector(
                          selectedItem: ing.item,
                          onSelected: (item) =>
                              setState(() => _ingredients[idx].item = item),
                          label: t.production.selectIngredient,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: ing.qtyController,
                          placeholder: Text(t.common.quantity),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton.ghost(
                        icon: const Icon(RadixIcons.cross2, size: 14),
                        onPressed: () {
                          setState(() {
                            _ingredients[idx].qtyController.dispose();
                            _ingredients.removeAt(idx);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
              if (_ingredients.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                    child: Text(t.production.addIngredient,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .mutedForeground)),
                  ),
                ),

              const SizedBox(height: 16),
              // Notes
              Text(t.production.notes,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                placeholder: Text(t.production.notes),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Button(
          style: const ButtonStyle.outline(),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.cancel),
        ),
        Button(
          style: const ButtonStyle.primary(),
          onPressed: _loading ? null : _save,
          child: Text(t.common.save),
        ),
      ],
    );
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(_IngredientEntry(
        qtyController: TextEditingController(text: '1'),
      ));
    });
  }

  Future<void> _save() async {
    if (_finishedItem == null || _ingredients.isEmpty) return;

    setState(() => _loading = true);
    final repo = ref.read(productionRepositoryProvider);

    final ingredients = _ingredients
        .where((e) => e.item != null)
        .map((e) => (
              ingredientItemId: e.item!.id,
              quantity: double.tryParse(e.qtyController.text) ?? 1,
            ))
        .toList();

    final outputQty =
        double.tryParse(_outputQtyController.text) ?? 1;

    final t = Translations.of(context);
    final isEdit = widget.recipeId != null;

    if (isEdit) {
      await repo.updateRecipe(
        id: widget.recipeId!,
        finishedItemId: _finishedItem!.id,
        outputQuantity: outputQty,
        notes: _notesController.text,
        ingredients: ingredients,
      );
    } else {
      await repo.createRecipe(
        storeId: widget.storeId,
        finishedItemId: _finishedItem!.id,
        outputQuantity: outputQty,
        notes: _notesController.text,
        ingredients: ingredients,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
      showToast(
        context: context,
        builder: (_, _) => SurfaceCard(
          child: Basic(
            title: Text(
                isEdit ? t.production.recipeUpdated : t.production.recipeCreated),
          ),
        ),
        location: ToastLocation.bottomRight,
      );
    }
  }
}

class _IngredientEntry {
  Item? item;
  final TextEditingController qtyController;

  _IngredientEntry({this.item, required this.qtyController});
}

/// Simple item selector using search.
class _ItemSelector extends ConsumerStatefulWidget {
  final Item? selectedItem;
  final ValueChanged<Item> onSelected;
  final String label;

  const _ItemSelector({
    this.selectedItem,
    required this.onSelected,
    required this.label,
  });

  @override
  ConsumerState<_ItemSelector> createState() => _ItemSelectorState();
}

class _ItemSelectorState extends ConsumerState<_ItemSelector> {
  final _searchController = TextEditingController();
  bool _showDropdown = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.selectedItem != null) {
      return GestureDetector(
        onTap: () => setState(() => _showDropdown = true),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(widget.selectedItem!.name,
                    style: const TextStyle(fontSize: 13)),
              ),
              Icon(RadixIcons.cross2,
                  size: 12, color: theme.colorScheme.mutedForeground),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _searchController,
          placeholder: Text(widget.label),
          onChanged: (_) => setState(() => _showDropdown = true),
        ),
        if (_showDropdown && _searchController.text.isNotEmpty)
          _SearchResults(
            query: _searchController.text,
            onSelected: (item) {
              widget.onSelected(item);
              _searchController.clear();
              setState(() => _showDropdown = false);
            },
          ),
      ],
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;
  final ValueChanged<Item> onSelected;

  const _SearchResults({required this.query, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resultsAsync = ref.watch(itemSearchProvider(query));

    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
      decoration: BoxDecoration(
        color: theme.colorScheme.popover,
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: resultsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(8),
              child: Text('No items'),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (_, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () => onSelected(item),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(item.name, style: const TextStyle(fontSize: 13)),
                ),
              );
            },
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(8),
          child: Text('$e'),
        ),
      ),
    );
  }
}
