import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../i18n/strings.g.dart';
import '../data/items_providers.dart';

class CategoryFormDialog extends ConsumerStatefulWidget {
  final String storeId;
  final Category? existingCategory;

  const CategoryFormDialog({
    super.key,
    required this.storeId,
    this.existingCategory,
  });

  @override
  ConsumerState<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  late final TextEditingController _nameController;
  String _selectedColor = '#6366F1';
  bool _saving = false;

  bool get _isEditing => widget.existingCategory != null;

  static const _colorOptions = [
    '#6366F1', '#EC4899', '#F59E0B', '#10B981',
    '#3B82F6', '#8B5CF6', '#EF4444', '#14B8A6',
    '#F97316', '#06B6D4', '#84CC16', '#A855F7',
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingCategory?.name ?? '');
    _selectedColor = widget.existingCategory?.color ?? '#6366F1';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);

    final repo = ref.read(categoryRepositoryProvider);

    if (_isEditing) {
      await repo.update(
        id: widget.existingCategory!.id,
        name: name,
        color: _selectedColor,
      );
    } else {
      await repo.create(
        storeId: widget.storeId,
        name: name,
        color: _selectedColor,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    if (!_isEditing) return;
    setState(() => _saving = true);
    final repo = ref.read(categoryRepositoryProvider);
    await repo.delete(widget.existingCategory!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(_isEditing ? t.items.editCategory : t.items.addCategory),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.items.categoryName,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              placeholder: Text(t.items.categoryName),
            ),
            const SizedBox(height: 16),
            Text('Color',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorOptions.map((color) {
                final isSelected = _selectedColor == color;
                final parsedColor = _parseHexColor(color);
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: parsedColor,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: theme.colorScheme.foreground, width: 2)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(RadixIcons.check,
                            size: 14, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        if (_isEditing)
          Button(
            style: const ButtonStyle.destructive(),
            onPressed: _saving ? null : _delete,
            child: Text(t.common.delete),
          ),
        const Spacer(),
        Button(
          style: const ButtonStyle.outline(),
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(t.common.cancel),
        ),
        const SizedBox(width: 8),
        Button(
          style: const ButtonStyle.primary(),
          onPressed: _saving ? null : _save,
          child: Text(t.common.save),
        ),
      ],
    );
  }

  Color _parseHexColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
