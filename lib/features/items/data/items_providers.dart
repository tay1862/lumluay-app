import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/database_provider.dart';
import 'category_repository.dart';
import 'item_repository.dart';
import 'modifier_repository.dart';
import 'variant_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoryRepository(db);
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ItemRepository(db);
});

final variantRepositoryProvider = Provider<VariantRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return VariantRepository(db);
});

final modifierRepositoryProvider = Provider<ModifierRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ModifierRepository(db);
});

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final auth = ref.watch(authProvider);
  final repo = ref.watch(categoryRepositoryProvider);
  if (auth.currentStoreId == null) return const Stream.empty();
  return repo.watchCategories(auth.currentStoreId!);
});

final itemsStreamProvider =
    StreamProvider.family<List<Item>, String?>((ref, categoryId) {
  final auth = ref.watch(authProvider);
  final repo = ref.watch(itemRepositoryProvider);
  if (auth.currentStoreId == null) return const Stream.empty();
  return repo.watchItems(auth.currentStoreId!, categoryId: categoryId);
});

final itemSearchProvider =
    FutureProvider.family<List<Item>, String>((ref, query) async {
  final auth = ref.watch(authProvider);
  final repo = ref.watch(itemRepositoryProvider);
  if (auth.currentStoreId == null) return [];
  return repo.search(auth.currentStoreId!, query);
});

final variantGroupsProvider =
    StreamProvider.family<List<VariantGroup>, String>((ref, itemId) {
  return ref.watch(variantRepositoryProvider).watchGroups(itemId);
});

final modifierGroupsProvider = StreamProvider<List<ModifierGroup>>((ref) {
  final auth = ref.watch(authProvider);
  if (auth.currentStoreId == null) return const Stream.empty();
  return ref
      .watch(modifierRepositoryProvider)
      .watchGroups(auth.currentStoreId!);
});
