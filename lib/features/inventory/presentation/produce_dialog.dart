import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../i18n/strings.g.dart';
import '../data/inventory_providers.dart';


class ProduceDialog extends ConsumerStatefulWidget {
  final String recipeId;
  final String storeId;
  final String finishedItemName;

  const ProduceDialog({
    super.key,
    required this.recipeId,
    required this.storeId,
    required this.finishedItemName,
  });

  @override
  ConsumerState<ProduceDialog> createState() => _ProduceDialogState();
}

class _ProduceDialogState extends ConsumerState<ProduceDialog> {
  final _batchQtyController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _batchQtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final ingredientsAsync =
        ref.watch(recipeIngredientsProvider(widget.recipeId));
    final batchQty = double.tryParse(_batchQtyController.text) ?? 1;

    return AlertDialog(
      title: Text('${t.production.produce}: ${widget.finishedItemName}'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Batch quantity
            Text(t.production.batchQuantity,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _batchQtyController,
                placeholder: const Text('1'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 16),

            // Ingredients status
            Text(t.production.ingredients,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ingredientsAsync.when(
              data: (ingredients) {
                return Column(
                  children: ingredients.map((ing) {
                    final required = ing.recipeItem.quantity * batchQty;
                    final hasEnough = ing.currentStock >= required;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            hasEnough
                                ? RadixIcons.checkCircled
                                : RadixIcons.crossCircled,
                            size: 16,
                            color: hasEnough
                                ? Colors.green
                                : theme.colorScheme.destructive,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(ing.ingredientName,
                                style: const TextStyle(fontSize: 13)),
                          ),
                          Text(
                            '${t.production.required}: ${required.toStringAsFixed(1)}',
                            style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.mutedForeground),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${t.production.available}: ${ing.currentStock.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: hasEnough
                                  ? theme.colorScheme.mutedForeground
                                  : theme.colorScheme.destructive,
                              fontWeight:
                                  hasEnough ? FontWeight.normal : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('$e'),
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
      actions: [
        Button(
          style: const ButtonStyle.outline(),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.cancel),
        ),
        Button(
          style: const ButtonStyle.primary(),
          onPressed: _loading ? null : () => _produce(batchQty),
          child: Text(t.production.produceNow),
        ),
      ],
    );
  }

  Future<void> _produce(double batchQty) async {
    final t = Translations.of(context);
    final repo = ref.read(productionRepositoryProvider);
    final auth = ref.read(authProvider);

    // Check stock availability
    final canDo = await repo.canProduce(
      storeId: widget.storeId,
      recipeId: widget.recipeId,
      quantity: batchQty,
    );

    if (!canDo) {
      if (mounted) {
        showToast(
          context: context,
          builder: (_, _) => SurfaceCard(
            child: Basic(
              title: Text(t.production.insufficientStock),
              leading: Icon(RadixIcons.crossCircled,
                  color: Theme.of(context).colorScheme.destructive),
            ),
          ),
          location: ToastLocation.bottomRight,
        );
      }
      return;
    }

    setState(() => _loading = true);

    final result = await repo.produce(
      storeId: widget.storeId,
      recipeId: widget.recipeId,
      quantity: batchQty,
      employeeId: auth.currentEmployee?.id,
      notes: _notesController.text,
    );

    if (mounted) {
      result.when(
        success: (_) {
          Navigator.of(context).pop();
          showToast(
            context: context,
            builder: (_, _) => SurfaceCard(
              child: Basic(
                title: Text(t.production.productionComplete),
                leading:
                    const Icon(RadixIcons.checkCircled, color: Colors.green),
              ),
            ),
            location: ToastLocation.bottomRight,
          );
        },
        failure: (e) {
          setState(() => _loading = false);
          showToast(
            context: context,
            builder: (_, _) => SurfaceCard(
              child: Basic(
                title: Text(e.message),
                leading: Icon(RadixIcons.crossCircled,
                    color: Theme.of(context).colorScheme.destructive),
              ),
            ),
            location: ToastLocation.bottomRight,
          );
        },
      );
    }
  }
}
