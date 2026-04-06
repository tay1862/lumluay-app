import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../i18n/strings.g.dart';
import '../data/customer_providers.dart';
import 'customer_form_dialog.dart';

class CustomerDetailDialog extends ConsumerWidget {
  final Customer customer;

  const CustomerDetailDialog({super.key, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final loyaltyAsync = ref.watch(loyaltyHistoryProvider(customer.id));

    return AlertDialog(
      title: Text(customer.name),
      content: SizedBox(
        width: 500,
        height: 450,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats row
            Row(
              children: [
                _StatCard(
                  label: t.customers.loyaltyBalance,
                  value: customer.loyaltyPoints.toStringAsFixed(0),
                  icon: RadixIcons.star,
                  color: Colors.amber,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: t.customers.totalSpent,
                  value: customer.totalSpent.toStringAsFixed(0),
                  icon: RadixIcons.barChart,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: t.customers.visits,
                  value: '${customer.visitCount}',
                  icon: RadixIcons.person,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Contact info
            if (customer.phone != null) ...[
              Row(
                children: [
                  Icon(RadixIcons.mobile, size: 14,
                      color: theme.colorScheme.mutedForeground),
                  const SizedBox(width: 8),
                  Text(customer.phone!),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (customer.email != null) ...[
              Row(
                children: [
                  Icon(RadixIcons.envelopeClosed, size: 14,
                      color: theme.colorScheme.mutedForeground),
                  const SizedBox(width: 8),
                  Text(customer.email!),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (customer.address != null) ...[
              Row(
                children: [
                  Icon(RadixIcons.home, size: 14,
                      color: theme.colorScheme.mutedForeground),
                  const SizedBox(width: 8),
                  Expanded(child: Text(customer.address!)),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (customer.notes != null && customer.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(customer.notes!,
                  style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.mutedForeground,
                      fontStyle: FontStyle.italic)),
            ],

            const SizedBox(height: 16),
            Text(t.customers.purchaseHistory,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),

            // Loyalty history
            Expanded(
              child: loyaltyAsync.when(
                data: (txns) {
                  if (txns.isEmpty) {
                    return Center(
                        child: Text(t.common.noData,
                            style: TextStyle(
                                color: theme.colorScheme.mutedForeground)));
                  }
                  return ListView.builder(
                    itemCount: txns.length,
                    itemBuilder: (context, index) {
                      final txn = txns[index];
                      final isEarn = txn.type == 'earn';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              isEarn
                                  ? RadixIcons.arrowUp
                                  : RadixIcons.arrowDown,
                              size: 14,
                              color:
                                  isEarn ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                txn.description,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: theme
                                        .colorScheme.mutedForeground),
                              ),
                            ),
                            Text(
                              '${isEarn ? '+' : ''}${txn.points.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isEarn
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Button(
          style: const ButtonStyle.outline(),
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (_) => CustomerFormDialog(
                storeId: customer.storeId,
                customer: customer,
              ),
            );
          },
          leading: const Icon(RadixIcons.pencil1, size: 14),
          child: Text(t.common.edit),
        ),
        Button(
          style: const ButtonStyle.outline(),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.close),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SurfaceCard(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 6),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .mutedForeground)),
            ],
          ),
        ),
      ),
    );
  }
}