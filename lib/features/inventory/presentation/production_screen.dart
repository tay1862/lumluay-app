import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../i18n/strings.g.dart';
import '../data/inventory_providers.dart';
import '../data/production_repository.dart';
import 'recipe_dialog.dart';
import 'produce_dialog.dart';

class ProductionScreen extends ConsumerWidget {
  const ProductionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final auth = ref.watch(authProvider);
    final storeId = auth.currentStoreId ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(t.production.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              Button(
                style: const ButtonStyle.outline(),
                onPressed: () => _showProductionLog(context, ref, storeId),
                leading: const Icon(RadixIcons.activityLog),
                child: Text(t.production.productionLog),
              ),
              const SizedBox(width: 8),
              Button(
                style: const ButtonStyle.primary(),
                onPressed: () => _showCreateRecipe(context, ref, storeId),
                leading: const Icon(RadixIcons.plus),
                child: Text(t.production.addRecipe),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _RecipeList(storeId: storeId)),
        ],
      ),
    );
  }

  void _showCreateRecipe(
      BuildContext context, WidgetRef ref, String storeId) {
    showDialog(
      context: context,
      builder: (_) => RecipeDialog(storeId: storeId),
    );
  }

  void _showProductionLog(
      BuildContext context, WidgetRef ref, String storeId) {
    showDialog(
      context: context,
      builder: (_) => _ProductionLogDialog(storeId: storeId),
    );
  }
}

class _RecipeList extends ConsumerWidget {
  final String storeId;
  const _RecipeList({required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final recipesAsync = ref.watch(recipesProvider(storeId));

    return recipesAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return Center(
            child: Text(t.production.noRecipes,
                style: TextStyle(color: theme.colorScheme.mutedForeground)),
          );
        }
        return ListView.separated(
          itemCount: recipes.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, index) =>
              _RecipeRow(recipe: recipes[index], storeId: storeId),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

class _RecipeRow extends ConsumerWidget {
  final RecipeWithItem recipe;
  final String storeId;
  const _RecipeRow({required this.recipe, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe.finishedItemName,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${recipe.ingredientCount} ${t.production.ingredients} · '
                  '${t.production.outputQuantity}: ${recipe.recipe.outputQuantity}',
                  style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.mutedForeground),
                ),
              ],
            ),
          ),
          Button(
            style: const ButtonStyle.primary(density: ButtonDensity.compact),
            onPressed: () => _showProduce(context, ref),
            child: Text(t.production.produce),
          ),
          const SizedBox(width: 8),
          IconButton.ghost(
            icon: const Icon(RadixIcons.pencil1),
            onPressed: () => _showEdit(context),
          ),
          IconButton.ghost(
            icon: Icon(RadixIcons.trash,
                color: theme.colorScheme.destructive),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }

  void _showProduce(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => ProduceDialog(
        recipeId: recipe.recipe.id,
        storeId: storeId,
        finishedItemName: recipe.finishedItemName,
      ),
    );
  }

  void _showEdit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => RecipeDialog(
        storeId: storeId,
        recipeId: recipe.recipe.id,
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.common.delete),
        content: Text(t.production.confirmDelete),
        actions: [
          Button(
            style: const ButtonStyle.outline(),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.common.cancel),
          ),
          Button(
            style: const ButtonStyle.destructive(),
            onPressed: () async {
              final repo = ref.read(productionRepositoryProvider);
              await repo.deleteRecipe(recipe.recipe.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                showToast(
                  context: context,
                  builder: (_, _) => SurfaceCard(
                    child: Basic(
                      title: Text(t.production.recipeDeleted),
                    ),
                  ),
                  location: ToastLocation.bottomRight,
                );
              }
            },
            child: Text(t.common.delete),
          ),
        ],
      ),
    );
  }
}

// ── Production Log Dialog ──

class _ProductionLogDialog extends ConsumerWidget {
  final String storeId;
  const _ProductionLogDialog({required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final logsAsync = ref.watch(productionLogsProvider(storeId));

    return AlertDialog(
      title: Text(t.production.productionLog),
      content: SizedBox(
        width: 500,
        height: 400,
        child: logsAsync.when(
          data: (logs) {
            if (logs.isEmpty) {
              return Center(
                child: Text(t.production.noLogs,
                    style:
                        TextStyle(color: theme.colorScheme.mutedForeground)),
              );
            }
            return ListView.separated(
              itemCount: logs.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (_, index) {
                final log = logs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(log.finishedItemName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text(
                              '${t.common.quantity}: ${log.log.quantityProduced}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(log.log.createdAt),
                        style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.mutedForeground),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
        ),
      ),
      actions: [
        Button(
          style: const ButtonStyle.outline(),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.close),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
