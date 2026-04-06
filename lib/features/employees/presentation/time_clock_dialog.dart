import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../i18n/strings.g.dart';
import '../data/employee_providers.dart';

class TimeClockDialog extends ConsumerStatefulWidget {
  final Employee employee;
  const TimeClockDialog({super.key, required this.employee});

  @override
  ConsumerState<TimeClockDialog> createState() => _TimeClockDialogState();
}

class _TimeClockDialogState extends ConsumerState<TimeClockDialog> {
  bool? _isClockedIn;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final repo = ref.read(employeeRepositoryProvider);
    final status = await repo.isClockedIn(widget.employee.id);
    if (mounted) setState(() => _isClockedIn = status);
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final entriesAsync = ref.watch(timeEntriesProvider(widget.employee.id));
    final dateFmt = DateFormat('MMM dd, yyyy');
    final timeFmt = DateFormat('HH:mm');

    return AlertDialog(
      title: Text('${t.employees.timeTracking} — ${widget.employee.name}'),
      content: SizedBox(
        width: 420,
        height: 380,
        child: Column(
          children: [
            // Clock In / Clock Out buttons
            Row(
              children: [
                if (_isClockedIn == null)
                  const Expanded(
                      child: Center(child: CircularProgressIndicator()))
                else ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: _isClockedIn!
                            ? Colors.green.withValues(alpha: 0.1)
                            : theme.colorScheme.muted.withValues(alpha: 0.3),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _isClockedIn!
                                ? RadixIcons.check
                                : RadixIcons.crossCircled,
                            size: 24,
                            color: _isClockedIn!
                                ? Colors.green
                                : theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isClockedIn!
                                ? t.employees.clockedIn
                                : t.employees.notClockedIn,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _isClockedIn!
                                  ? Colors.green
                                  : theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Button(
                    style: _isClockedIn!
                        ? const ButtonStyle.destructive()
                        : const ButtonStyle.primary(),
                    onPressed: _loading ? null : _toggle,
                    child: Text(
                      _isClockedIn!
                          ? t.employees.clockOut
                          : t.employees.clockIn,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Time entries header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(t.employees.timeEntries,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),

            // Entries list
            Expanded(
              child: entriesAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return Center(
                      child: Text(t.employees.noTimeEntries,
                          style: TextStyle(
                              color: theme.colorScheme.mutedForeground)),
                    );
                  }
                  return ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (_, index) {
                      final e = entries[index];
                      final dur = e.clockOut != null
                          ? e.clockOut!.difference(e.clockIn)
                          : DateTime.now().difference(e.clockIn);
                      final hours = dur.inHours;
                      final mins = dur.inMinutes % 60;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(dateFmt.format(e.clockIn),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${timeFmt.format(e.clockIn)} — ${e.clockOut != null ? timeFmt.format(e.clockOut!) : '...'}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: theme
                                            .colorScheme.mutedForeground),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: e.clockOut != null
                                    ? theme.colorScheme.muted
                                        .withValues(alpha: 0.3)
                                    : Colors.green.withValues(alpha: 0.1),
                              ),
                              child: Text(
                                '${hours}h ${mins}m',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: e.clockOut != null
                                      ? theme.colorScheme.foreground
                                      : Colors.green,
                                ),
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
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.close),
        ),
      ],
    );
  }

  Future<void> _toggle() async {
    setState(() => _loading = true);
    final repo = ref.read(employeeRepositoryProvider);
    final t = Translations.of(context);

    if (_isClockedIn!) {
      await repo.clockOut(widget.employee.id);
      if (mounted) {
        showToast(
          context: context,
          builder: (_, overlay) =>
              SurfaceCard(child: Basic(title: Text(t.employees.clockedOut))),
        );
      }
    } else {
      await repo.clockIn(widget.employee.id);
      if (mounted) {
        showToast(
          context: context,
          builder: (_, overlay) =>
              SurfaceCard(child: Basic(title: Text(t.employees.clockedIn))),
        );
      }
    }

    if (mounted) {
      await _checkStatus();
      setState(() => _loading = false);
    }
  }
}
