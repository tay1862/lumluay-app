import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../i18n/strings.g.dart';
import '../data/items_providers.dart';

class ModifierPickerDialog extends ConsumerStatefulWidget {
  const ModifierPickerDialog({
    super.key,
    required this.item,
    required this.onConfirmed,
  });

  final Item item;
  final void Function(List<Modifier> selectedModifiers) onConfirmed;

  @override
  ConsumerState<ModifierPickerDialog> createState() =>
      _ModifierPickerDialogState();
}

class _ModifierPickerDialogState extends ConsumerState<ModifierPickerDialog> {
  final Map<String, Set<String>> _selected = {}; // groupId -> set of modifierIds

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.item.name} — ${t.items.modifiers}'),
      content: SizedBox(
        width: 360,
        child: FutureBuilder<List<ModifierGroup>>(
          future: ref
              .read(modifierRepositoryProvider)
              .getGroupsForItem(widget.item.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()));
            }
            final groups = snapshot.data!;
            if (groups.isEmpty) return Text(t.common.noData);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: groups.map((group) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(group.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        if (group.minSelect > 0 || group.maxSelect > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            '(${group.minSelect}-${group.maxSelect})',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    _ModifierOptions(
                      groupId: group.id,
                      maxSelect: group.maxSelect,
                      selectedIds: _selected[group.id] ?? {},
                      onToggle: (modifierId) {
                        setState(() {
                          final set =
                              _selected.putIfAbsent(group.id, () => {});
                          if (set.contains(modifierId)) {
                            set.remove(modifierId);
                          } else {
                            if (group.maxSelect > 0 &&
                                set.length >= group.maxSelect) {
                              return;
                            }
                            set.add(modifierId);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
            );
          },
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
          onPressed: () async {
            final nav = Navigator.of(context);
            // Fetch modifier objects
            final allModifiers = <Modifier>[];
            final repo = ref.read(modifierRepositoryProvider);
            for (final groupId in _selected.keys) {
              final mods = await repo.getModifiers(groupId);
              allModifiers.addAll(
                  mods.where((m) => _selected[groupId]!.contains(m.id)));
            }
            if (mounted) {
              nav.pop();
              widget.onConfirmed(allModifiers);
            }
          },
          child: Text(t.common.confirm),
        ),
      ],
    );
  }
}

class _ModifierOptions extends ConsumerWidget {
  const _ModifierOptions({
    required this.groupId,
    required this.maxSelect,
    required this.selectedIds,
    required this.onToggle,
  });

  final String groupId;
  final int maxSelect;
  final Set<String> selectedIds;
  final void Function(String modifierId) onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modsAsync = ref.watch(
      StreamProvider<List<Modifier>>((ref) {
        return ref.watch(modifierRepositoryProvider).watchModifiers(groupId);
      }),
    );

    return modsAsync.when(
      data: (modifiers) => Wrap(
        spacing: 8,
        runSpacing: 6,
        children: modifiers.map((m) {
          final selected = selectedIds.contains(m.id);
          return Button(
            style: selected
                ? const ButtonStyle.primary(density: ButtonDensity.compact)
                : const ButtonStyle.outline(density: ButtonDensity.compact),
            onPressed: () => onToggle(m.id),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(m.name),
                if (m.priceAdjustment != 0)
                  Text(
                    '+₭${m.priceAdjustment.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 11),
                  ),
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
