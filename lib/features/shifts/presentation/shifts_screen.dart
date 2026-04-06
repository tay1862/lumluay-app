import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../i18n/strings.g.dart';
import '../data/shift_providers.dart';
import 'cash_movement_dialog.dart';
import 'close_shift_dialog.dart';
import 'open_shift_dialog.dart';

class ShiftsScreen extends ConsumerWidget {
  const ShiftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final auth = ref.watch(authProvider);
    final storeId = auth.currentStoreId ?? '';
    final shiftAsync = ref.watch(currentShiftProvider(storeId));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(t.shifts.currentShift,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              Button(
                style: const ButtonStyle.outline(),
                onPressed: () => _showHistory(context, storeId),
                leading: const Icon(RadixIcons.timer),
                child: Text(t.shifts.shiftHistory),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current shift or Open button
          Expanded(
            child: shiftAsync.when(
              data: (shift) {
                if (shift == null) {
                  return _NoShift(storeId: storeId);
                }
                return _ActiveShift(shift: shift);
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showHistory(BuildContext context, String storeId) {
    showDialog(
      context: context,
      builder: (_) => _ShiftHistoryDialog(storeId: storeId),
    );
  }
}

class _NoShift extends ConsumerWidget {
  final String storeId;
  const _NoShift({required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(RadixIcons.clock, size: 48,
              color: theme.colorScheme.mutedForeground),
          const SizedBox(height: 12),
          Text(t.shifts.noShift,
              style: TextStyle(
                  fontSize: 16, color: theme.colorScheme.mutedForeground)),
          const SizedBox(height: 16),
          Button(
            style: const ButtonStyle.primary(),
            onPressed: () => _openShift(context),
            leading: const Icon(RadixIcons.play),
            child: Text(t.shifts.openShift),
          ),
        ],
      ),
    );
  }

  void _openShift(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => OpenShiftDialog(storeId: storeId),
    );
  }
}

class _ActiveShift extends ConsumerWidget {
  final Shift shift;
  const _ActiveShift({required this.shift});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final timeFmt = DateFormat('HH:mm');
    final dateFmt = DateFormat('MMM dd, yyyy');
    final movementsAsync = ref.watch(cashMovementsProvider(shift.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Shift info card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(t.shifts.currentShift,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(
                      '${dateFmt.format(shift.openedAt)} ${timeFmt.format(shift.openedAt)}',
                      style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.mutedForeground),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoTile(
                        label: t.shifts.openingCash,
                        value:
                            '₭${shift.openingCash.toStringAsFixed(0)}'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: Button(
                style: const ButtonStyle.outline(),
                onPressed: () => _cashIn(context),
                leading: const Icon(RadixIcons.plus),
                child: Text(t.shifts.cashIn),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Button(
                style: const ButtonStyle.outline(),
                onPressed: () => _cashOut(context),
                leading: const Icon(RadixIcons.minus),
                child: Text(t.shifts.cashOut),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Button(
                style: const ButtonStyle.destructive(),
                onPressed: () => _closeShift(context),
                leading: const Icon(RadixIcons.stop),
                child: Text(t.shifts.closeShift),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Cash movements
        Text(t.shifts.cashMovements,
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Expanded(
          child: movementsAsync.when(
            data: (movements) {
              if (movements.isEmpty) {
                return Center(
                  child: Text(t.shifts.noMovements,
                      style: TextStyle(
                          color: theme.colorScheme.mutedForeground)),
                );
              }
              return ListView.separated(
                itemCount: movements.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (_, index) {
                  final m = movements[index];
                  final isIn = m.type == 'in';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          isIn ? RadixIcons.plus : RadixIcons.minus,
                          size: 16,
                          color: isIn ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isIn ? t.shifts.cashIn : t.shifts.cashOut,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                              if (m.reason.isNotEmpty)
                                Text(m.reason,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: theme
                                            .colorScheme.mutedForeground)),
                            ],
                          ),
                        ),
                        Text(
                          '${isIn ? '+' : '-'}₭${m.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isIn ? Colors.green : Colors.red,
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
    );
  }

  void _cashIn(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CashMovementDialog(shiftId: shift.id, type: 'in'),
    );
  }

  void _cashOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CashMovementDialog(shiftId: shift.id, type: 'out'),
    );
  }

  void _closeShift(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CloseShiftDialog(shift: shift),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12, color: theme.colorScheme.mutedForeground)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ShiftHistoryDialog extends ConsumerWidget {
  final String storeId;
  const _ShiftHistoryDialog({required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final historyAsync = ref.watch(shiftHistoryProvider(storeId));
    final dateFmt = DateFormat('MMM dd');
    final timeFmt = DateFormat('HH:mm');

    return AlertDialog(
      title: Text(t.shifts.shiftHistory),
      content: SizedBox(
        width: 500,
        height: 400,
        child: historyAsync.when(
          data: (shifts) {
            if (shifts.isEmpty) {
              return Center(
                child: Text(t.shifts.noShift,
                    style: TextStyle(
                        color: theme.colorScheme.mutedForeground)),
              );
            }
            return ListView.separated(
              itemCount: shifts.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (_, index) {
                final s = shifts[index];
                final shift = s.shift;
                final isOpen = shift.closedAt == null;
                final diff = shift.closingCash != null &&
                        shift.expectedCash != null
                    ? shift.closingCash! - shift.expectedCash!
                    : null;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOpen ? Colors.green : theme.colorScheme.muted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateFmt.format(shift.openedAt),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${timeFmt.format(shift.openedAt)} — ${shift.closedAt != null ? timeFmt.format(shift.closedAt!) : '...'}',
                            style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.mutedForeground),
                          ),
                          const Spacer(),
                          if (s.employeeName != null)
                            Text(s.employeeName!,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.mutedForeground)),
                        ],
                      ),
                      if (!isOpen) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const SizedBox(width: 16),
                            Text(
                              '${t.shifts.openingCash}: ₭${shift.openingCash.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${t.shifts.closingCash}: ₭${shift.closingCash?.toStringAsFixed(0) ?? '-'}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (diff != null) ...[
                              const SizedBox(width: 16),
                              Text(
                                '${t.shifts.difference}: ${diff >= 0 ? '+' : ''}₭${diff.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: diff.abs() < 1
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
        ),
      ),
      actions: [
        Button(
          style: const ButtonStyle.outline(),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.close),
        ),
      ],
    );
  }
}
