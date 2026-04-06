import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/constants/currency_service.dart';
import '../data/sales_providers.dart';

/// Customer Display System — shows the current cart to the customer
/// on a second screen or device. Read-only view of the active sale.
class CustomerDisplayScreen extends ConsumerWidget {
  const CustomerDisplayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Store branding
              Text(
                'Lumluay POS',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Customer Display',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),

              if (cart.isEmpty) ...[
                const Spacer(),
                Icon(RadixIcons.desktop,
                    size: 64, color: theme.colorScheme.mutedForeground),
                const SizedBox(height: 16),
                Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your order will appear here',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                const Spacer(),
              ] else ...[
                // Items list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final ci = cart.items[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Quantity badge
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${ci.quantity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Name + details
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ci.item.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (ci.variant != null)
                                    Text(
                                      ci.variant!.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  if (ci.modifiers.isNotEmpty)
                                    Text(
                                      ci.modifiers
                                          .map((m) => m.name)
                                          .join(', '),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme
                                            .colorScheme.mutedForeground,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Line total
                            Text(
                              CurrencyService.format(
                                  ci.lineTotal, cart.currencyCode),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Totals panel
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.accent,
                    border: Border(
                      top: BorderSide(color: theme.colorScheme.border),
                    ),
                  ),
                  child: Column(
                    children: [
                      _row(
                        'Subtotal',
                        CurrencyService.format(
                            cart.subtotal, cart.currencyCode),
                        theme,
                      ),
                      if (cart.taxAmount > 0)
                        _row(
                          'Tax',
                          CurrencyService.format(
                              cart.taxAmount, cart.currencyCode),
                          theme,
                        ),
                      if (cart.orderDiscount > 0)
                        _row(
                          'Discount',
                          '-${CurrencyService.format(cart.orderDiscount, cart.currencyCode)}',
                          theme,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            CurrencyService.format(
                                cart.total, cart.currencyCode),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${cart.itemCount} item(s)',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.mutedForeground)),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
