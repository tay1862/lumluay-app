import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';

/// Joined model: recipe + finished item name.
class RecipeWithItem {
  final Recipe recipe;
  final String finishedItemName;
  final String? sku;
  final int ingredientCount;

  const RecipeWithItem({
    required this.recipe,
    required this.finishedItemName,
    this.sku,
    this.ingredientCount = 0,
  });
}

/// Joined model: recipe ingredient + ingredient item name.
class RecipeIngredient {
  final RecipeItem recipeItem;
  final String ingredientName;
  final String? sku;
  final double currentStock;

  const RecipeIngredient({
    required this.recipeItem,
    required this.ingredientName,
    this.sku,
    this.currentStock = 0,
  });
}

/// Production log with recipe + item info.
class ProductionLogWithInfo {
  final ProductionLog log;
  final String finishedItemName;
  final String? employeeName;

  const ProductionLogWithInfo({
    required this.log,
    required this.finishedItemName,
    this.employeeName,
  });
}

class ProductionRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  ProductionRepository(this._db);

  // ── Recipes ──

  /// Watch all recipes for a store, joined with finished item name.
  Stream<List<RecipeWithItem>> watchRecipes(String storeId) {
    final query = _db.select(_db.recipes).join([
      innerJoin(
          _db.items, _db.items.id.equalsExp(_db.recipes.finishedItemId)),
    ])
      ..where(_db.recipes.storeId.equals(storeId))
      ..orderBy([OrderingTerm.asc(_db.items.name)]);

    return query.watch().asyncMap((rows) async {
      final results = <RecipeWithItem>[];
      for (final row in rows) {
        final recipe = row.readTable(_db.recipes);
        final item = row.readTable(_db.items);
        final count = await (_db.selectOnly(_db.recipeItems)
              ..addColumns([_db.recipeItems.id.count()])
              ..where(_db.recipeItems.recipeId.equals(recipe.id)))
            .map((row) => row.read(_db.recipeItems.id.count()) ?? 0)
            .getSingle();
        results.add(RecipeWithItem(
          recipe: recipe,
          finishedItemName: item.name,
          sku: item.sku,
          ingredientCount: count,
        ));
      }
      return results;
    });
  }

  /// Get a single recipe by ID.
  Future<Recipe?> getRecipe(String id) async {
    return (_db.select(_db.recipes)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Create a new recipe.
  Future<Result<String>> createRecipe({
    required String storeId,
    required String finishedItemId,
    double outputQuantity = 1.0,
    String notes = '',
    required List<({String ingredientItemId, double quantity})> ingredients,
  }) async {
    try {
      final id = _uuid.v4();
      await _db.transaction(() async {
        await _db.into(_db.recipes).insert(RecipesCompanion.insert(
              id: id,
              storeId: storeId,
              finishedItemId: finishedItemId,
              outputQuantity: Value(outputQuantity),
              notes: Value(notes),
            ));

        for (final ing in ingredients) {
          await _db.into(_db.recipeItems).insert(RecipeItemsCompanion.insert(
                id: _uuid.v4(),
                recipeId: id,
                ingredientItemId: ing.ingredientItemId,
                quantity: ing.quantity,
              ));
        }
      });
      return Success(id);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to create recipe: $e'));
    }
  }

  /// Update a recipe (replace ingredients).
  Future<Result<void>> updateRecipe({
    required String id,
    required String finishedItemId,
    double outputQuantity = 1.0,
    String notes = '',
    required List<({String ingredientItemId, double quantity})> ingredients,
  }) async {
    try {
      await _db.transaction(() async {
        await (_db.update(_db.recipes)..where((t) => t.id.equals(id))).write(
          RecipesCompanion(
            finishedItemId: Value(finishedItemId),
            outputQuantity: Value(outputQuantity),
            notes: Value(notes),
            updatedAt: Value(DateTime.now()),
          ),
        );

        // Remove old ingredients and insert new ones
        await (_db.delete(_db.recipeItems)
              ..where((t) => t.recipeId.equals(id)))
            .go();

        for (final ing in ingredients) {
          await _db.into(_db.recipeItems).insert(RecipeItemsCompanion.insert(
                id: _uuid.v4(),
                recipeId: id,
                ingredientItemId: ing.ingredientItemId,
                quantity: ing.quantity,
              ));
        }
      });
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to update recipe: $e'));
    }
  }

  /// Delete a recipe and its ingredients.
  Future<Result<void>> deleteRecipe(String id) async {
    try {
      await _db.transaction(() async {
        await (_db.delete(_db.recipeItems)
              ..where((t) => t.recipeId.equals(id)))
            .go();
        await (_db.delete(_db.recipes)..where((t) => t.id.equals(id))).go();
      });
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to delete recipe: $e'));
    }
  }

  // ── Recipe Ingredients ──

  /// Watch ingredients for a recipe, joined with item name + current stock.
  Stream<List<RecipeIngredient>> watchIngredients(String recipeId) {
    final query = _db.select(_db.recipeItems).join([
      innerJoin(_db.items,
          _db.items.id.equalsExp(_db.recipeItems.ingredientItemId)),
    ])
      ..where(_db.recipeItems.recipeId.equals(recipeId));

    return query.watch().asyncMap((rows) async {
      final results = <RecipeIngredient>[];
      for (final row in rows) {
        final ri = row.readTable(_db.recipeItems);
        final item = row.readTable(_db.items);

        // Get current stock level
        final level = await (_db.select(_db.inventoryLevels)
              ..where((t) => t.itemId.equals(item.id)))
            .getSingleOrNull();

        results.add(RecipeIngredient(
          recipeItem: ri,
          ingredientName: item.name,
          sku: item.sku,
          currentStock: level?.quantity ?? 0,
        ));
      }
      return results;
    });
  }

  // ── Production ──

  /// Produce: decrement ingredients, increment finished item, log production.
  Future<Result<void>> produce({
    required String storeId,
    required String recipeId,
    required double quantity,
    String? employeeId,
    String? notes,
  }) async {
    try {
      await _db.transaction(() async {
        // Get recipe
        final recipe = await (_db.select(_db.recipes)
              ..where((t) => t.id.equals(recipeId)))
            .getSingle();

        // Get ingredients
        final ingredients = await (_db.select(_db.recipeItems)
              ..where((t) => t.recipeId.equals(recipeId)))
            .get();

        final outputQty = recipe.outputQuantity * quantity;

        // Decrement each ingredient
        for (final ing in ingredients) {
          final requiredQty = ing.quantity * quantity;
          await _adjustStock(
            storeId: storeId,
            itemId: ing.ingredientItemId,
            change: -requiredQty,
            reason: 'production',
            employeeId: employeeId,
          );
        }

        // Increment finished item
        await _adjustStock(
          storeId: storeId,
          itemId: recipe.finishedItemId,
          change: outputQty,
          reason: 'production',
          employeeId: employeeId,
        );

        // Log production
        await _db.into(_db.productionLogs).insert(
              ProductionLogsCompanion.insert(
                id: _uuid.v4(),
                storeId: storeId,
                recipeId: recipeId,
                quantityProduced: outputQty,
                employeeId: Value(employeeId),
                notes: Value(notes ?? ''),
              ),
            );
      });
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to produce: $e'));
    }
  }

  /// Check if we have enough ingredients to produce a recipe N times.
  Future<bool> canProduce({
    required String storeId,
    required String recipeId,
    required double quantity,
  }) async {
    final ingredients = await (_db.select(_db.recipeItems)
          ..where((t) => t.recipeId.equals(recipeId)))
        .get();

    for (final ing in ingredients) {
      final level = await (_db.select(_db.inventoryLevels)
            ..where((t) =>
                t.itemId.equals(ing.ingredientItemId) &
                t.storeId.equals(storeId)))
          .getSingleOrNull();

      final available = level?.quantity ?? 0;
      if (available < ing.quantity * quantity) return false;
    }
    return true;
  }

  /// Watch production logs for a store.
  Stream<List<ProductionLogWithInfo>> watchProductionLogs(String storeId) {
    final query = _db.select(_db.productionLogs).join([
      innerJoin(_db.recipes,
          _db.recipes.id.equalsExp(_db.productionLogs.recipeId)),
      innerJoin(
          _db.items, _db.items.id.equalsExp(_db.recipes.finishedItemId)),
    ])
      ..where(_db.productionLogs.storeId.equals(storeId))
      ..orderBy([OrderingTerm.desc(_db.productionLogs.createdAt)]);

    return query.watch().map((rows) => rows.map((row) {
          final log = row.readTable(_db.productionLogs);
          final item = row.readTable(_db.items);
          return ProductionLogWithInfo(
            log: log,
            finishedItemName: item.name,
          );
        }).toList());
  }

  // ── Private Helpers ──

  Future<void> _adjustStock({
    required String storeId,
    required String itemId,
    required double change,
    required String reason,
    String? employeeId,
  }) async {
    // Record adjustment
    await _db.into(_db.stockAdjustments).insert(
          StockAdjustmentsCompanion.insert(
            id: _uuid.v4(),
            storeId: storeId,
            itemId: itemId,
            quantityChange: change,
            reason: reason,
            employeeId: Value(employeeId),
          ),
        );

    // Update inventory level
    final level = await (_db.select(_db.inventoryLevels)
          ..where(
              (t) => t.storeId.equals(storeId) & t.itemId.equals(itemId)))
        .getSingleOrNull();

    if (level != null) {
      await (_db.update(_db.inventoryLevels)
            ..where((t) => t.id.equals(level.id)))
          .write(InventoryLevelsCompanion(
        quantity: Value(level.quantity + change),
        updatedAt: Value(DateTime.now()),
      ));
    } else {
      await _db.into(_db.inventoryLevels).insert(
            InventoryLevelsCompanion.insert(
              id: _uuid.v4(),
              itemId: itemId,
              storeId: storeId,
              quantity: Value(change > 0 ? change : 0),
            ),
          );
    }
  }
}
