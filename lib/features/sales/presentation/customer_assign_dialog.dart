import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../i18n/strings.g.dart';
import '../../customers/data/customer_providers.dart';

class CustomerAssignDialog extends ConsumerStatefulWidget {
  final ValueChanged<String> onSelected;

  const CustomerAssignDialog({super.key, required this.onSelected});

  @override
  ConsumerState<CustomerAssignDialog> createState() =>
      _CustomerAssignDialogState();
}

class _CustomerAssignDialogState extends ConsumerState<CustomerAssignDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return AlertDialog(
      title: Text(t.customers.assignCustomer),
      content: SizedBox(
        width: 400,
        height: 350,
        child: Column(
          children: [
            TextField(
              placeholder: Text(t.common.search),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _query.isEmpty
                  ? _AllCustomers(onSelected: _select)
                  : _SearchResults(query: _query, onSelected: _select),
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
      ],
    );
  }

  void _select(Customer customer) {
    widget.onSelected(customer.id);
    Navigator.of(context).pop();
  }
}

class _AllCustomers extends ConsumerWidget {
  final ValueChanged<Customer> onSelected;
  const _AllCustomers({required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);
    final customersAsync = ref.watch(customersProvider);

    return customersAsync.when(
      data: (customers) {
        if (customers.isEmpty) {
          return Center(
            child: Text(t.customers.noCustomers,
                style: TextStyle(color: theme.colorScheme.mutedForeground)),
          );
        }
        return ListView.builder(
          itemCount: customers.length,
          itemBuilder: (_, index) =>
              _CustomerTile(customer: customers[index], onTap: onSelected),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;
  final ValueChanged<Customer> onSelected;
  const _SearchResults({required this.query, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resultsAsync = ref.watch(customerSearchProvider(query));

    return resultsAsync.when(
      data: (customers) {
        if (customers.isEmpty) {
          return Center(
            child: Text('No results',
                style: TextStyle(color: theme.colorScheme.mutedForeground)),
          );
        }
        return ListView.builder(
          itemCount: customers.length,
          itemBuilder: (_, index) =>
              _CustomerTile(customer: customers[index], onTap: onSelected),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  final Customer customer;
  final ValueChanged<Customer> onTap;

  const _CustomerTile({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onTap(customer),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            const Icon(RadixIcons.person, size: 16),
            const SizedBox(width: 10),
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
            Text('${customer.loyaltyPoints.toStringAsFixed(0)} pts',
                style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.mutedForeground)),
          ],
        ),
      ),
    );
  }
}
