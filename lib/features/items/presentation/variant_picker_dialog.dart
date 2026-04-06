import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../i18n/strings.g.dart';
import '../data/items_providers.dart';

class VariantPickerDialog extends ConsumerWidget {
  const VariantPickerDialog({
    super.key,
    required this.item,
    required this.onSelected,
  });

  final Item item;
  final void Function(Variant variant) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(variantGroupsProvider(item.id));

    return AlertDialog(
      title: Text('${item.name} — ${t.items.variants}'),
      content: SizedBox(
        width: 360,
        child: groupsAsync.when(
          data: (groups) {
            if (groups.isEmpty) {
              return Text(t.common.noData);
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: groups.map((group) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    _VariantOptions(
                      groupId: group.id,
                      onSelected: (variant) {
                        Navigator.of(context).pop();
                        onSelected(variant);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
            );
          },
          loading: () => const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text('$e'),
        ),
      ),
      actions: [
        Button(
          style: const ButtonStyle.outline(),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.cancel),
        ),
      ],
    );
  }
}

class _VariantOptions extends ConsumerWidget {
  const _VariantOptions({
    required this.groupId,
    required this.onSelected,
  });

  final String groupId;
  final void Function(Variant variant) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variantsAsync = ref.watch(
      StreamProvider<List<Variant>>((ref) {
        return ref.watch(variantRepositoryProvider).watchVariants(groupId);
      }),
    );

    return variantsAsync.when(
      data: (variants) => Wrap(
        spacing: 8,
        runSpacing: 6,
        children: variants.map((v) {
          return Button(
            style: const ButtonStyle.outline(density: ButtonDensity.compact),
            onPressed: () => onSelected(v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(v.name),
                if (v.price > 0)
                  Text('₭${v.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 11)),
              ],
            ),
          );
        }).toList(),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('$e'),
    );
  }
}
