import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/result.dart';

class CustomerRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  CustomerRepository(this._db);

  /// Watch all customers for a store.
  Stream<List<Customer>> watchCustomers(String storeId) {
    return (_db.select(_db.customers)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Search customers by name or phone.
  Future<List<Customer>> searchCustomers(String storeId, String query) async {
    final escaped = _escapeLike(query);
    return (_db.select(_db.customers)
          ..where((t) =>
              t.storeId.equals(storeId) &
              (t.name.like('%$escaped%') | t.phone.like('%$escaped%')))
          ..orderBy([(t) => OrderingTerm.asc(t.name)])
          ..limit(20))
        .get();
  }

  /// Get a single customer.
  Future<Customer?> getCustomer(String id) {
    return (_db.select(_db.customers)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Create a new customer.
  Future<Result<String>> createCustomer({
    required String storeId,
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    DateTime? birthday,
  }) async {
    try {
      final id = _uuid.v4();
      await _db.into(_db.customers).insert(CustomersCompanion.insert(
            id: id,
            storeId: storeId,
            name: name,
            phone: Value(phone),
            email: Value(email),
            address: Value(address),
            notes: Value(notes),
            birthday: Value(birthday),
          ));
      return Success(id);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to create customer: $e'));
    }
  }

  /// Update a customer.
  Future<Result<void>> updateCustomer({
    required String id,
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    DateTime? birthday,
  }) async {
    try {
      await (_db.update(_db.customers)..where((t) => t.id.equals(id)))
          .write(CustomersCompanion(
        name: Value(name),
        phone: Value(phone),
        email: Value(email),
        address: Value(address),
        notes: Value(notes),
        birthday: Value(birthday),
        updatedAt: Value(DateTime.now()),
      ));
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to update customer: $e'));
    }
  }

  /// Delete a customer.
  Future<Result<void>> deleteCustomer(String id) async {
    try {
      await (_db.delete(_db.customers)..where((t) => t.id.equals(id))).go();
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to delete customer: $e'));
    }
  }

  /// Add loyalty points (earn).
  Future<Result<void>> addLoyaltyPoints({
    required String customerId,
    required double points,
    String? receiptId,
    String description = '',
  }) async {
    try {
      await _db.transaction(() async {
        await _db.into(_db.loyaltyTransactions).insert(
              LoyaltyTransactionsCompanion.insert(
                id: _uuid.v4(),
                customerId: customerId,
                receiptId: Value(receiptId),
                points: points,
                type: 'earn',
                description: Value(description),
              ),
            );

        final customer = await (_db.select(_db.customers)
              ..where((t) => t.id.equals(customerId)))
            .getSingle();

        await (_db.update(_db.customers)
              ..where((t) => t.id.equals(customerId)))
            .write(CustomersCompanion(
          loyaltyPoints: Value(customer.loyaltyPoints + points),
          updatedAt: Value(DateTime.now()),
        ));
      });
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to add loyalty points: $e'));
    }
  }

  /// Redeem loyalty points.
  Future<Result<void>> redeemLoyaltyPoints({
    required String customerId,
    required double points,
    String? receiptId,
    String description = '',
  }) async {
    try {
      await _db.transaction(() async {
        final customer = await (_db.select(_db.customers)
              ..where((t) => t.id.equals(customerId)))
            .getSingle();

        if (customer.loyaltyPoints < points) {
          throw Exception('Insufficient loyalty points');
        }

        await _db.into(_db.loyaltyTransactions).insert(
              LoyaltyTransactionsCompanion.insert(
                id: _uuid.v4(),
                customerId: customerId,
                receiptId: Value(receiptId),
                points: -points,
                type: 'redeem',
                description: Value(description),
              ),
            );

        await (_db.update(_db.customers)
              ..where((t) => t.id.equals(customerId)))
            .write(CustomersCompanion(
          loyaltyPoints: Value(customer.loyaltyPoints - points),
          updatedAt: Value(DateTime.now()),
        ));
      });
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseException(message: 'Failed to redeem points: $e'));
    }
  }

  /// Record a visit + spending.
  Future<void> recordVisit(String customerId, double amount) async {
    final customer = await (_db.select(_db.customers)
          ..where((t) => t.id.equals(customerId)))
        .getSingle();

    await (_db.update(_db.customers)
          ..where((t) => t.id.equals(customerId)))
        .write(CustomersCompanion(
      visitCount: Value(customer.visitCount + 1),
      totalSpent: Value(customer.totalSpent + amount),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Watch loyalty transactions for a customer.
  Stream<List<LoyaltyTransaction>> watchLoyaltyHistory(String customerId) {
    return (_db.select(_db.loyaltyTransactions)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  static String _escapeLike(String input) =>
      input.replaceAll('\\', '\\\\').replaceAll('%', '\\%').replaceAll('_', '\\_');
}
