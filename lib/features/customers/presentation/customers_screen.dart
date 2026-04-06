import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../i18n/strings.g.dart';
import '../data/customer_providers.dart';
import 'customer_form_dialog.dart';
import 'customer_detail_dialog.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider);
    final storeId = auth.currentStoreId ?? '';
    final customersAsync = ref.watch(customersProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(t.customers.allCustomers,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              Button(
                style: const ButtonStyle.primary(),
                onPressed: () => _showAddCustomer(context, storeId),
                leading: const Icon(RadixIcons.plus),
                child: Text(t.customers.addCustomer),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search bar
          TextField(
            placeholder: Text(t.common.search),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 12),
          // Customer list
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                final filtered = _searchQuery.isEmpty
                    ? customers
                    : customers.where((c) {
                        final q = _searchQuery.toLowerCase();
                        return c.name.toLowerCase().contains(q) ||
                            (c.phone?.contains(q) ?? false) ||
                            (c.email?.toLowerCase().contains(q) ?? false);
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? t.customers.noCustomers
                          : t.common.noData,
                      style: TextStyle(
                          color: theme.colorScheme.mutedForeground),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final customer = filtered[index];
                    return _CustomerRow(customer: customer);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCustomer(BuildContext context, String storeId) {
    showDialog(
      context: context,
      builder: (_) => CustomerFormDialog(storeId: storeId),
    );
  }
}

class _CustomerRow extends ConsumerWidget {
  final Customer customer;
  const _CustomerRow({required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => CustomerDetailDialog(customer: customer),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (customer.phone != null)
                    Text(customer.phone!,
                        style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.mutedForeground)),
                ],
              ),
            ),
            // Loyalty points
            if (customer.loyaltyPoints > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(RadixIcons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      customer.loyaltyPoints.toStringAsFixed(0),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.amber),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 12),
            // Total spent
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  customer.totalSpent.toStringAsFixed(0),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${customer.visitCount} ${t.customers.visits}',
                  style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.mutedForeground),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(RadixIcons.chevronRight, size: 16),
          ],
        ),
      ),
    );
  }
}
