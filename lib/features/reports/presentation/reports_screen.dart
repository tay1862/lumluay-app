import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../i18n/strings.g.dart';
import '../data/report_providers.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final auth = ref.watch(authProvider);
    final storeId = auth.currentStoreId ?? '';
    final dateRange = ref.watch(dateRangeProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header + date range selector
          Row(
            children: [
              Expanded(
                child: Text(t.reports.salesSummary,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              _DateRangeButtons(dateRange: dateRange),
            ],
          ),
          const SizedBox(height: 16),

          // Tab bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _TabButton(
                  label: t.reports.salesSummary,
                  selected: _tabIndex == 0,
                  onPressed: () => setState(() => _tabIndex = 0),
                ),
                const SizedBox(width: 4),
                _TabButton(
                  label: t.reports.salesByItem,
                  selected: _tabIndex == 1,
                  onPressed: () => setState(() => _tabIndex = 1),
                ),
                const SizedBox(width: 4),
                _TabButton(
                  label: t.reports.salesByCategory,
                  selected: _tabIndex == 2,
                  onPressed: () => setState(() => _tabIndex = 2),
                ),
                const SizedBox(width: 4),
                _TabButton(
                  label: t.reports.salesByEmployee,
                  selected: _tabIndex == 3,
                  onPressed: () => setState(() => _tabIndex = 3),
                ),
                const SizedBox(width: 4),
                _TabButton(
                  label: t.reports.salesByPayment,
                  selected: _tabIndex == 4,
                  onPressed: () => setState(() => _tabIndex = 4),
                ),
                const SizedBox(width: 4),
                _TabButton(
                  label: t.reports.salesByHour,
                  selected: _tabIndex == 5,
                  onPressed: () => setState(() => _tabIndex = 5),
                ),
                const SizedBox(width: 4),
                _TabButton(
                  label: t.reports.taxReport,
                  selected: _tabIndex == 6,
                  onPressed: () => setState(() => _tabIndex = 6),
                ),
                const SizedBox(width: 4),
                _TabButton(
                  label: t.reports.discountReport,
                  selected: _tabIndex == 7,
                  onPressed: () => setState(() => _tabIndex = 7),
                ),
                const SizedBox(width: 4),
                _TabButton(
                  label: t.reports.customerReport,
                  selected: _tabIndex == 8,
                  onPressed: () => setState(() => _tabIndex = 8),
                ),
                const SizedBox(width: 4),
                _TabButton(
                  label: t.reports.inventoryReport,
                  selected: _tabIndex == 9,
                  onPressed: () => setState(() => _tabIndex = 9),
                ),
                const SizedBox(width: 4),
                _TabButton(
                  label: t.reports.expenses,
                  selected: _tabIndex == 10,
                  onPressed: () => setState(() => _tabIndex = 10),
                ),
                const SizedBox(width: 4),
                _TabButton(
                  label: t.reports.profitAndLoss,
                  selected: _tabIndex == 11,
                  onPressed: () => setState(() => _tabIndex = 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: switch (_tabIndex) {
              0 => _SummaryTab(
                  storeId: storeId,
                  from: dateRange.from,
                  to: dateRange.to),
              1 => _ByItemTab(
                  storeId: storeId,
                  from: dateRange.from,
                  to: dateRange.to),
              2 => _ByCategoryTab(
                  storeId: storeId,
                  from: dateRange.from,
                  to: dateRange.to),
              3 => _ByEmployeeTab(
                  storeId: storeId,
                  from: dateRange.from,
                  to: dateRange.to),
              4 => _ByPaymentTab(
                  storeId: storeId,
                  from: dateRange.from,
                  to: dateRange.to),
              5 => _ByHourTab(
                  storeId: storeId,
                  from: dateRange.from,
                  to: dateRange.to),
              6 => _TaxReportTab(
                  storeId: storeId,
                  from: dateRange.from,
                  to: dateRange.to),
              7 => _DiscountReportTab(
                  storeId: storeId,
                  from: dateRange.from,
                  to: dateRange.to),
              8 => _CustomerReportTab(
                  storeId: storeId,
                  from: dateRange.from,
                  to: dateRange.to),
              9 => _InventoryReportTab(storeId: storeId),
              10 => _ExpensesTab(
                  storeId: storeId,
                  from: dateRange.from,
                  to: dateRange.to),
              11 => _ProfitAndLossTab(
                  storeId: storeId,
                  from: dateRange.from,
                  to: dateRange.to),
              _ => const SizedBox(),
            },
          ),
        ],
      ),
    );
  }
}

class _DateRangeButtons extends ConsumerWidget {
  final DateRangeState dateRange;
  const _DateRangeButtons({required this.dateRange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);

    return Row(
      children: [
        _RangeChip(
          label: t.reports.today,
          selected: dateRange.label == 'today',
          onPressed: () {
            final now = DateTime.now();
            ref.read(dateRangeProvider.notifier).state = DateRangeState(
              from: DateTime(now.year, now.month, now.day),
              to: DateTime(now.year, now.month, now.day + 1),
              label: 'today',
            );
          },
        ),
        const SizedBox(width: 4),
        _RangeChip(
          label: t.reports.thisWeek,
          selected: dateRange.label == 'week',
          onPressed: () {
            final now = DateTime.now();
            final weekStart =
                now.subtract(Duration(days: now.weekday - 1));
            ref.read(dateRangeProvider.notifier).state = DateRangeState(
              from: DateTime(weekStart.year, weekStart.month, weekStart.day),
              to: DateTime(now.year, now.month, now.day + 1),
              label: 'week',
            );
          },
        ),
        const SizedBox(width: 4),
        _RangeChip(
          label: t.reports.thisMonth,
          selected: dateRange.label == 'month',
          onPressed: () {
            final now = DateTime.now();
            ref.read(dateRangeProvider.notifier).state = DateRangeState(
              from: DateTime(now.year, now.month, 1),
              to: DateTime(now.year, now.month, now.day + 1),
              label: 'month',
            );
          },
        ),
      ],
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;
  const _RangeChip(
      {required this.label, required this.selected, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Button(
      style: selected
          ? const ButtonStyle.primary(density: ButtonDensity.compact)
          : const ButtonStyle.outline(density: ButtonDensity.compact),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;
  const _TabButton(
      {required this.label, required this.selected, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Button(
      style: selected
          ? const ButtonStyle.secondary(density: ButtonDensity.compact)
          : const ButtonStyle.ghost(density: ButtonDensity.compact),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

// ── Summary Tab ──

class _SummaryTab extends ConsumerWidget {
  final String storeId;
  final DateTime from;
  final DateTime to;
  const _SummaryTab(
      {required this.storeId, required this.from, required this.to});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final summaryAsync =
        ref.watch(salesSummaryProvider((storeId, from, to)));

    return summaryAsync.when(
      data: (summary) => SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: _MetricCard(
                  label: t.shifts.totalSales,
                  value: '₭${summary.totalSales.toStringAsFixed(0)}',
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _MetricCard(
                  label: t.common.discount,
                  value: '₭${summary.totalDiscount.toStringAsFixed(0)}',
                )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _MetricCard(
                  label: t.common.tax,
                  value: '₭${summary.totalTax.toStringAsFixed(0)}',
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _MetricCard(
                  label: '# Receipts',
                  value: '${summary.receiptCount}',
                )),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text('Net Sales',
                        style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.mutedForeground)),
                    const Spacer(),
                    Text('₭${summary.netSales.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12, color: theme.colorScheme.mutedForeground)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ── By Item Tab ──

class _ByItemTab extends ConsumerWidget {
  final String storeId;
  final DateTime from;
  final DateTime to;
  const _ByItemTab(
      {required this.storeId, required this.from, required this.to});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dataAsync =
        ref.watch(salesByItemProvider((storeId, from, to)));

    return dataAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
              child: Text(Translations.of(context).common.noData,
                  style: TextStyle(
                      color: theme.colorScheme.mutedForeground)));
        }
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (_, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text('${index + 1}.',
                      style: TextStyle(
                          color: theme.colorScheme.mutedForeground)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item.itemName,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  Text('×${item.quantity.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.mutedForeground)),
                  const SizedBox(width: 16),
                  Text('₭${item.total.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

// ── By Category Tab ──

class _ByCategoryTab extends ConsumerWidget {
  final String storeId;
  final DateTime from;
  final DateTime to;
  const _ByCategoryTab(
      {required this.storeId, required this.from, required this.to});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dataAsync = ref.watch(
        salesByCategoryProvider((storeId, from, to)));

    return dataAsync.when(
      data: (cats) {
        if (cats.isEmpty) {
          return Center(
              child: Text(Translations.of(context).common.noData,
                  style: TextStyle(
                      color: theme.colorScheme.mutedForeground)));
        }
        return ListView.separated(
          itemCount: cats.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (_, index) {
            final cat = cats[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat.categoryName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                        Text('${cat.itemCount} items',
                            style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.mutedForeground)),
                      ],
                    ),
                  ),
                  Text('₭${cat.total.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

// ── By Employee Tab ──

class _ByEmployeeTab extends ConsumerWidget {
  final String storeId;
  final DateTime from;
  final DateTime to;
  const _ByEmployeeTab(
      {required this.storeId, required this.from, required this.to});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dataAsync = ref.watch(
        salesByEmployeeProvider((storeId, from, to)));

    return dataAsync.when(
      data: (emps) {
        if (emps.isEmpty) {
          return Center(
              child: Text(Translations.of(context).common.noData,
                  style: TextStyle(
                      color: theme.colorScheme.mutedForeground)));
        }
        return ListView.separated(
          itemCount: emps.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (_, index) {
            final emp = emps[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(emp.employeeName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                        Text('${emp.receiptCount} receipts',
                            style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.mutedForeground)),
                      ],
                    ),
                  ),
                  Text('₭${emp.total.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

// ── By Payment Tab ──

class _ByPaymentTab extends ConsumerWidget {
  final String storeId;
  final DateTime from;
  final DateTime to;
  const _ByPaymentTab(
      {required this.storeId, required this.from, required this.to});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dataAsync = ref.watch(
        salesByPaymentProvider((storeId, from, to)));

    return dataAsync.when(
      data: (methods) {
        if (methods.isEmpty) {
          return Center(
              child: Text(Translations.of(context).common.noData,
                  style: TextStyle(
                      color: theme.colorScheme.mutedForeground)));
        }
        return ListView.separated(
          itemCount: methods.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (_, index) {
            final m = methods[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    switch (m.method) {
                      'cash' => RadixIcons.archive,
                      'qr' => RadixIcons.mobile,
                      'card' => RadixIcons.idCard,
                      _ => RadixIcons.questionMarkCircled,
                    },
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.method.toUpperCase(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                        Text('${m.count} transactions',
                            style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.mutedForeground)),
                      ],
                    ),
                  ),
                  Text('₭${m.total.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

// ── By Hour Tab ──

class _ByHourTab extends ConsumerWidget {
  final String storeId;
  final DateTime from;
  final DateTime to;
  const _ByHourTab(
      {required this.storeId, required this.from, required this.to});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dataAsync =
        ref.watch(salesByHourProvider((storeId, from, to)));

    return dataAsync.when(
      data: (hours) {
        final maxTotal =
            hours.fold(0.0, (m, h) => h.total > m ? h.total : m);
        return ListView.separated(
          itemCount: hours.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (_, index) {
            final h = hours[index];
            final barWidth = maxTotal > 0 ? h.total / maxTotal : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      '${h.hour.toString().padLeft(2, '0')}:00',
                      style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.mutedForeground),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: barWidth,
                        minHeight: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '${h.count}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.mutedForeground),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      '₭${h.total.toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

// ── Tax Report Tab ──

class _TaxReportTab extends ConsumerWidget {
  final String storeId;
  final DateTime from;
  final DateTime to;
  const _TaxReportTab(
      {required this.storeId, required this.from, required this.to});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final dataAsync =
        ref.watch(taxReportProvider((storeId, from, to)));

    return dataAsync.when(
      data: (taxes) {
        if (taxes.isEmpty) {
          return Center(
              child: Text(t.common.noData,
                  style: TextStyle(
                      color: theme.colorScheme.mutedForeground)));
        }
        return ListView.separated(
          itemCount: taxes.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (_, index) {
            final tax = taxes[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tax.taxName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                        if (tax.rate > 0)
                          Text('${t.reports.taxRate}: ${tax.rate}%',
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      theme.colorScheme.mutedForeground)),
                      ],
                    ),
                  ),
                  Text('₭${tax.taxCollected.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

// ── Discount Report Tab ──

class _DiscountReportTab extends ConsumerWidget {
  final String storeId;
  final DateTime from;
  final DateTime to;
  const _DiscountReportTab(
      {required this.storeId, required this.from, required this.to});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final dataAsync =
        ref.watch(discountReportProvider((storeId, from, to)));

    return dataAsync.when(
      data: (report) => SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: _MetricCard(
                  label: t.reports.totalDiscount,
                  value: '₭${report.totalDiscount.toStringAsFixed(0)}',
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _MetricCard(
                  label: t.reports.avgDiscount,
                  value: '₭${report.avgDiscount.toStringAsFixed(0)}',
                )),
              ],
            ),
            const SizedBox(height: 12),
            _MetricCard(
              label: t.reports.receiptsWithDiscount,
              value: '${report.receiptCount}',
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

// ── Customer Report Tab ──

class _CustomerReportTab extends ConsumerWidget {
  final String storeId;
  final DateTime from;
  final DateTime to;
  const _CustomerReportTab(
      {required this.storeId, required this.from, required this.to});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final dataAsync =
        ref.watch(customerReportProvider((storeId, from, to)));

    return dataAsync.when(
      data: (customers) {
        if (customers.isEmpty) {
          return Center(
              child: Text(t.common.noData,
                  style: TextStyle(
                      color: theme.colorScheme.mutedForeground)));
        }
        return ListView.separated(
          itemCount: customers.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (_, index) {
            final c = customers[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text('${index + 1}.',
                      style: TextStyle(
                          color: theme.colorScheme.mutedForeground)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.customerName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                        Text('${c.visitCount} ${t.reports.visits}',
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    theme.colorScheme.mutedForeground)),
                      ],
                    ),
                  ),
                  Text('₭${c.totalSpent.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

// ── Inventory Report Tab ──

class _InventoryReportTab extends ConsumerWidget {
  final String storeId;
  const _InventoryReportTab({required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final dataAsync = ref.watch(inventoryReportProvider(storeId));

    return dataAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
              child: Text(t.common.noData,
                  style: TextStyle(
                      color: theme.colorScheme.mutedForeground)));
        }
        double totalValue = 0;
        for (final i in items) {
          totalValue += i.costValue;
        }
        return Column(
          children: [
            _MetricCard(
              label: t.reports.stockValue,
              value: '₭${totalValue.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (_, index) {
                  final item = items[index];
                  final isLow =
                      item.quantity <= item.lowStockThreshold;
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        if (isLow)
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(RadixIcons.exclamationTriangle,
                                size: 16, color: Color(0xFFEF4444)),
                          ),
                        Expanded(
                          child: Text(item.itemName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500)),
                        ),
                        Text(
                            '${item.quantity.toStringAsFixed(0)} / ${item.lowStockThreshold.toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: 13,
                                color: isLow
                                    ? const Color(0xFFEF4444)
                                    : theme.colorScheme
                                        .mutedForeground)),
                        const SizedBox(width: 16),
                        Text(
                            '₭${item.costValue.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

// ── Expenses Tab ──

class _ExpensesTab extends ConsumerWidget {
  final String storeId;
  final DateTime from;
  final DateTime to;
  const _ExpensesTab(
      {required this.storeId, required this.from, required this.to});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final dataAsync =
        ref.watch(expenseSummaryProvider((storeId, from, to)));

    return dataAsync.when(
      data: (expenses) {
        if (expenses.isEmpty) {
          return Center(
              child: Text(t.reports.noExpenses,
                  style: TextStyle(
                      color: theme.colorScheme.mutedForeground)));
        }
        double totalExpenses = 0;
        for (final e in expenses) {
          totalExpenses += e.total;
        }
        return Column(
          children: [
            _MetricCard(
              label: t.reports.expenses,
              value: '₭${totalExpenses.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: expenses.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (_, index) {
                  final exp = expenses[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(exp.category,
                                  style: const TextStyle(
                                      fontWeight:
                                          FontWeight.w500)),
                              Text('${exp.count} entries',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme
                                          .mutedForeground)),
                            ],
                          ),
                        ),
                        Text(
                            '₭${exp.total.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

// ── Profit & Loss Tab ──

class _ProfitAndLossTab extends ConsumerWidget {
  final String storeId;
  final DateTime from;
  final DateTime to;
  const _ProfitAndLossTab(
      {required this.storeId, required this.from, required this.to});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final dataAsync =
        ref.watch(profitAndLossProvider((storeId, from, to)));

    return dataAsync.when(
      data: (pnl) => SingleChildScrollView(
        child: Column(
          children: [
            _MetricCard(
              label: t.reports.revenue,
              value: '₭${pnl.revenue.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 8),
            _MetricCard(
              label: t.reports.cogs,
              value: '-₭${pnl.cogs.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(t.reports.grossProfit,
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.mutedForeground)),
                    const Spacer(),
                    Text('₭${pnl.grossProfit.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: pnl.grossProfit >= 0
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFEF4444))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _MetricCard(
              label: t.reports.expenses,
              value: '-₭${pnl.expenses.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(t.reports.netProfit,
                        style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.mutedForeground)),
                    const Spacer(),
                    Text('₭${pnl.netProfit.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: pnl.netProfit >= 0
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFEF4444))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}
