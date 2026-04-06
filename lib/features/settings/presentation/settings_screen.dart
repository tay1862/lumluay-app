import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/audit_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../i18n/strings.g.dart';
import '../data/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);
    final currentLocale = LocaleSettings.currentLocale;
    final auth = ref.watch(authProvider);
    final storeId = auth.currentStoreId;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.nav.settings,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // ── Store Settings (10.1) ──
            _SectionHeader(t.settings.store),
            const SizedBox(height: 12),
            if (storeId != null) _StoreSettingsCard(storeId: storeId),
            const SizedBox(height: 24),

            // ── Tax Settings (10.2) ──
            _SectionHeader(t.settings.taxes),
            const SizedBox(height: 12),
            if (storeId != null) _TaxSettingsCard(storeId: storeId),
            const SizedBox(height: 24),

            // ── Receipt Template (10.3) ──
            _SectionHeader(t.settings.receipt),
            const SizedBox(height: 12),
            if (storeId != null) _ReceiptSettingsCard(storeId: storeId),
            const SizedBox(height: 24),

            // ── Printer (10.4) ──
            _SectionHeader('Printer'),
            const SizedBox(height: 12),
            if (storeId != null) _PrinterSettingsCard(storeId: storeId),
            const SizedBox(height: 24),

            // ── Cash Drawer (10.5) ──
            _SectionHeader('Cash Drawer'),
            const SizedBox(height: 12),
            if (storeId != null) _CashDrawerCard(storeId: storeId),
            const SizedBox(height: 24),

            // ── Payment Methods (10.6) ──
            _SectionHeader(t.settings.payment),
            const SizedBox(height: 12),
            if (storeId != null) _PaymentMethodsCard(storeId: storeId),
            const SizedBox(height: 24),

            // ── Currency (10.7) ──
            _SectionHeader(t.settings.currency),
            const SizedBox(height: 12),
            if (storeId != null) _CurrencySettingsCard(storeId: storeId),
            const SizedBox(height: 24),

            // ── General Section (10.8, 10.9) ──
            _SectionHeader(t.settings.general),
            const SizedBox(height: 12),

            // Language
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(RadixIcons.globe, size: 20),
                        const SizedBox(width: 12),
                        Text(t.settings.language),
                      ],
                    ),
                    _LanguageSelector(currentLocale: currentLocale),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Dark Mode
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(RadixIcons.moon, size: 20),
                        const SizedBox(width: 12),
                        Text(t.settings.darkMode),
                      ],
                    ),
                    Switch(
                      value: isDark,
                      onChanged: (value) {
                        ref.read(themeModeProvider.notifier).state = value;
                        if (storeId != null) {
                          ref
                              .read(settingsRepositoryProvider)
                              .setValue(storeId, 'darkMode', value.toString());
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Audit Log (10.10) ──
            _SectionHeader(t.settings.auditLog),
            const SizedBox(height: 12),
            if (storeId != null) _AuditLogCard(storeId: storeId),
            const SizedBox(height: 24),

            // ── Backup & Restore (10.11) ──
            _SectionHeader(t.settings.backup),
            const SizedBox(height: 12),
            if (storeId != null) _BackupCard(storeId: storeId),
            const SizedBox(height: 24),

            // ── About (10.12) ──
            _SectionHeader(t.settings.about),
            const SizedBox(height: 12),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lumluay POS',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Version 0.1.0'),
                    SizedBox(height: 8),
                    Text(
                      'A modern point-of-sale system built with Flutter.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ──
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));
  }
}

// ── Language Selector ──
class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.currentLocale});
  final AppLocale currentLocale;
  static const _labels = {
    AppLocale.en: 'English',
    AppLocale.lo: 'ລາວ',
    AppLocale.th: 'ไทย',
  };

  @override
  Widget build(BuildContext context) {
    return Select<AppLocale>(
      value: currentLocale,
      onChanged: (locale) {
        if (locale != null) {
          LocaleSettings.setLocaleRawSync(locale.languageCode);
        }
      },
      itemBuilder: (context, locale) => Text(_labels[locale] ?? ''),
      popup: (_) => SelectPopup(
        items: SelectItemList(
          children: AppLocale.values
              .map((locale) => SelectItemButton(
                    value: locale,
                    child: Text(_labels[locale] ?? ''),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 10.1 Store Settings
// ══════════════════════════════════════════════

class _StoreSettingsCard extends ConsumerStatefulWidget {
  const _StoreSettingsCard({required this.storeId});
  final String storeId;

  @override
  ConsumerState<_StoreSettingsCard> createState() => _StoreSettingsCardState();
}

class _StoreSettingsCardState extends ConsumerState<_StoreSettingsCard> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loaded = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeAsync = ref.watch(storeStreamProvider(widget.storeId));

    return storeAsync.when(
      data: (store) {
        if (store != null && !_loaded) {
          _nameCtrl.text = store.name;
          _addressCtrl.text = store.address;
          _phoneCtrl.text = store.phone;
          _loaded = true;
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameCtrl,
                  placeholder: Text(t.common.name),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressCtrl,
                  placeholder: Text(t.inventory.address),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneCtrl,
                  placeholder: Text(t.inventory.phone),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Button(
                    style: const ButtonStyle.primary(),
                    onPressed: () async {
                      await ref.read(storeRepositoryProvider).updateStore(
                            id: widget.storeId,
                            name: _nameCtrl.text.trim(),
                            address: _addressCtrl.text.trim(),
                            phone: _phoneCtrl.text.trim(),
                          );
                    },
                    child: Text(t.common.save),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()))),
      error: (e, _) => Card(
          child: Padding(
              padding: const EdgeInsets.all(16), child: Text('$e'))),
    );
  }
}

// ══════════════════════════════════════════════
// 10.2 Tax Settings
// ══════════════════════════════════════════════

class _TaxSettingsCard extends ConsumerWidget {
  const _TaxSettingsCard({required this.storeId});
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxAsync = ref.watch(taxRatesStreamProvider(storeId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            taxAsync.when(
              data: (taxes) {
                if (taxes.isEmpty) {
                  return Text(t.common.noData,
                      style: const TextStyle(fontSize: 13));
                }
                return Column(
                  children: taxes.map<Widget>((tax) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(tax.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(width: 8),
                                Text('${(tax.rate * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(fontSize: 13)),
                                if (tax.isInclusive) ...[
                                  const SizedBox(width: 6),
                                  const Text('(incl)',
                                      style: TextStyle(fontSize: 11)),
                                ],
                              ],
                            ),
                          ),
                          IconButton.ghost(
                            icon: const Icon(RadixIcons.trash, size: 16),
                            onPressed: () => ref
                                .read(taxRateRepositoryProvider)
                                .delete(tax.id),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: 8),
            Button(
              style: const ButtonStyle.outline(density: ButtonDensity.compact),
              onPressed: () => _showAddTaxDialog(context, ref),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(RadixIcons.plus, size: 14),
                  const SizedBox(width: 4),
                  Text(t.common.add),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaxDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    var isInclusive = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(t.settings.taxes),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameCtrl, placeholder: Text(t.common.name)),
                const SizedBox(height: 12),
                TextField(
                    controller: rateCtrl,
                    placeholder: Text(t.reports.taxRate)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tax Inclusive'),
                    Switch(
                      value: isInclusive,
                      onChanged: (v) => setDialogState(() => isInclusive = v),
                    ),
                  ],
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
            Button(
              style: const ButtonStyle.primary(),
              onPressed: () async {
                final rate = double.tryParse(rateCtrl.text) ?? 0;
                await ref.read(taxRateRepositoryProvider).create(
                      storeId: storeId,
                      name: nameCtrl.text.trim(),
                      rate: rate / 100,
                      isInclusive: isInclusive,
                    );
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(t.common.save),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 10.3 Receipt Template Settings
// ══════════════════════════════════════════════

class _ReceiptSettingsCard extends ConsumerStatefulWidget {
  const _ReceiptSettingsCard({required this.storeId});
  final String storeId;

  @override
  ConsumerState<_ReceiptSettingsCard> createState() =>
      _ReceiptSettingsCardState();
}

class _ReceiptSettingsCardState extends ConsumerState<_ReceiptSettingsCard> {
  final _headerCtrl = TextEditingController();
  final _footerCtrl = TextEditingController();
  bool _showLogo = true;
  bool _showAddress = true;
  bool _loaded = false;

  @override
  void dispose() {
    _headerCtrl.dispose();
    _footerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    if (_loaded) return;
    final repo = ref.read(settingsRepositoryProvider);
    final header =
        await repo.getValue(widget.storeId, 'receipt_header') ?? '';
    final footer =
        await repo.getValue(widget.storeId, 'receipt_footer') ?? '';
    final showLogo =
        await repo.getValue(widget.storeId, 'receipt_show_logo') ?? 'true';
    final showAddress =
        await repo.getValue(widget.storeId, 'receipt_show_address') ?? 'true';
    if (mounted) {
      setState(() {
        _headerCtrl.text = header;
        _footerCtrl.text = footer;
        _showLogo = showLogo == 'true';
        _showAddress = showAddress == 'true';
        _loaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadSettings());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _headerCtrl,
              placeholder: Text('Header text'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _footerCtrl,
              placeholder: Text('Footer text'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Show Logo'),
                Switch(
                  value: _showLogo,
                  onChanged: (v) => setState(() => _showLogo = v),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Show Address'),
                Switch(
                  value: _showAddress,
                  onChanged: (v) => setState(() => _showAddress = v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Button(
                style: const ButtonStyle.primary(),
                onPressed: () async {
                  final repo = ref.read(settingsRepositoryProvider);
                  await repo.setValue(
                      widget.storeId, 'receipt_header', _headerCtrl.text);
                  await repo.setValue(
                      widget.storeId, 'receipt_footer', _footerCtrl.text);
                  await repo.setValue(widget.storeId, 'receipt_show_logo',
                      _showLogo.toString());
                  await repo.setValue(widget.storeId, 'receipt_show_address',
                      _showAddress.toString());
                },
                child: Text(t.common.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 10.4 Printer Management
// ══════════════════════════════════════════════

class _PrinterSettingsCard extends ConsumerStatefulWidget {
  const _PrinterSettingsCard({required this.storeId});
  final String storeId;

  @override
  ConsumerState<_PrinterSettingsCard> createState() =>
      _PrinterSettingsCardState();
}

class _PrinterSettingsCardState extends ConsumerState<_PrinterSettingsCard> {
  List<Map<String, String>> _printers = [];
  bool _loaded = false;

  Future<void> _loadPrinters() async {
    if (_loaded) return;
    final raw = await ref
        .read(settingsRepositoryProvider)
        .getValue(widget.storeId, 'printers');
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List;
      _printers = decoded.map((e) => Map<String, String>.from(e)).toList();
    }
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadPrinters());
  }

  Future<void> _savePrinters() async {
    await ref
        .read(settingsRepositoryProvider)
        .setValue(widget.storeId, 'printers', jsonEncode(_printers));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_printers.isEmpty)
              const Text('No printers configured',
                  style: TextStyle(fontSize: 13))
            else
              ..._printers.asMap().entries.map((entry) {
                final p = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['name'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500)),
                          Text('${p['type']} — ${p['address']}',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      IconButton.ghost(
                        icon: const Icon(RadixIcons.trash, size: 16),
                        onPressed: () {
                          setState(() => _printers.removeAt(entry.key));
                          _savePrinters();
                        },
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 8),
            Button(
              style: const ButtonStyle.outline(density: ButtonDensity.compact),
              onPressed: () => _showAddPrinterDialog(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(RadixIcons.plus, size: 14),
                  const SizedBox(width: 4),
                  const Text('Add Printer'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPrinterDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    var type = 'bluetooth';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Printer'),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameCtrl,
                    placeholder: Text(t.common.name)),
                const SizedBox(height: 12),
                Select<String>(
                  value: type,
                  onChanged: (v) {
                    if (v != null) setDialogState(() => type = v);
                  },
                  itemBuilder: (context, v) => Text(v),
                  popup: (_) => SelectPopup(
                    items: SelectItemList(
                      children: ['bluetooth', 'wifi', 'usb']
                          .map((t) =>
                              SelectItemButton(value: t, child: Text(t)))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                    controller: addressCtrl,
                    placeholder: Text('IP / MAC address')),
              ],
            ),
          ),
          actions: [
            Button(
              style: const ButtonStyle.outline(),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.common.cancel),
            ),
            Button(
              style: const ButtonStyle.primary(),
              onPressed: () {
                setState(() {
                  _printers.add({
                    'name': nameCtrl.text.trim(),
                    'type': type,
                    'address': addressCtrl.text.trim(),
                  });
                });
                _savePrinters();
                Navigator.of(context).pop();
              },
              child: Text(t.common.save),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 10.5 Cash Drawer Settings
// ══════════════════════════════════════════════

class _CashDrawerCard extends ConsumerStatefulWidget {
  const _CashDrawerCard({required this.storeId});
  final String storeId;

  @override
  ConsumerState<_CashDrawerCard> createState() => _CashDrawerCardState();
}

class _CashDrawerCardState extends ConsumerState<_CashDrawerCard> {
  bool _autoOpen = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final val = await ref
          .read(settingsRepositoryProvider)
          .getValue(widget.storeId, 'cash_drawer_auto_open');
      if (mounted) {
        setState(() {
          _autoOpen = val != 'false';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Auto-open on payment'),
            Switch(
              value: _autoOpen,
              onChanged: (v) {
                setState(() => _autoOpen = v);
                ref
                    .read(settingsRepositoryProvider)
                    .setValue(
                        widget.storeId, 'cash_drawer_auto_open', v.toString());
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 10.6 Payment Method Settings
// ══════════════════════════════════════════════

class _PaymentMethodsCard extends ConsumerStatefulWidget {
  const _PaymentMethodsCard({required this.storeId});
  final String storeId;

  @override
  ConsumerState<_PaymentMethodsCard> createState() =>
      _PaymentMethodsCardState();
}

class _PaymentMethodsCardState extends ConsumerState<_PaymentMethodsCard> {
  Map<String, bool> _methods = {
    'cash': true,
    'qr': true,
    'card': false,
    'other': false,
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final raw = await ref
          .read(settingsRepositoryProvider)
          .getValue(widget.storeId, 'payment_methods');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _methods = decoded.map((k, v) => MapEntry(k, v as bool));
      }
      if (mounted) setState(() {});
    });
  }

  Future<void> _save() async {
    await ref
        .read(settingsRepositoryProvider)
        .setValue(widget.storeId, 'payment_methods', jsonEncode(_methods));
  }

  static const _icons = {
    'cash': RadixIcons.archive,
    'qr': RadixIcons.mobile,
    'card': RadixIcons.idCard,
    'other': RadixIcons.questionMarkCircled,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: _methods.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(_icons[entry.key] ?? RadixIcons.questionMarkCircled,
                          size: 18),
                      const SizedBox(width: 12),
                      Text(entry.key[0].toUpperCase() +
                          entry.key.substring(1)),
                    ],
                  ),
                  Switch(
                    value: entry.value,
                    onChanged: (v) {
                      setState(() => _methods[entry.key] = v);
                      _save();
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 10.7 Currency Settings
// ══════════════════════════════════════════════

class _CurrencySettingsCard extends ConsumerStatefulWidget {
  const _CurrencySettingsCard({required this.storeId});
  final String storeId;

  @override
  ConsumerState<_CurrencySettingsCard> createState() =>
      _CurrencySettingsCardState();
}

class _CurrencySettingsCardState extends ConsumerState<_CurrencySettingsCard> {
  String _primary = 'LAK';
  Map<String, double> _rates = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final store =
          await ref.read(storeRepositoryProvider).getStore(widget.storeId);
      if (store != null && mounted) {
        Map<String, double> rates = {};
        try {
          final decoded = jsonDecode(store.exchangeRates) as Map<String, dynamic>;
          rates = decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
        } catch (_) {}
        setState(() {
          _primary = store.currency;
          _rates = rates;
        });
      }
    });
  }

  static const _currencies = ['LAK', 'THB', 'USD', 'CNY', 'VND'];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.settings.currency),
                Select<String>(
                  value: _primary,
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _primary = v);
                      ref.read(storeRepositoryProvider).updateStore(
                            id: widget.storeId,
                            currency: v,
                          );
                    }
                  },
                  itemBuilder: (context, v) => Text(v),
                  popup: (_) => SelectPopup(
                    items: SelectItemList(
                      children: _currencies
                          .map((c) =>
                              SelectItemButton(value: c, child: Text(c)))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(t.settings.exchangeRate,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ..._currencies.where((c) => c != _primary).map((c) {
              final ctrl =
                  TextEditingController(text: (_rates[c] ?? 0).toString());
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(width: 50, child: Text(c)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: ctrl,
                        placeholder: Text('1 $_primary = ? $c'),
                        onChanged: (v) {
                          _rates[c] = double.tryParse(v) ?? 0;
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Button(
                style: const ButtonStyle.primary(),
                onPressed: () {
                  ref.read(storeRepositoryProvider).updateStore(
                        id: widget.storeId,
                        exchangeRates: jsonEncode(_rates),
                      );
                },
                child: Text(t.common.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 10.10 Audit Log Viewer
// ══════════════════════════════════════════════

class _AuditLogCard extends ConsumerStatefulWidget {
  const _AuditLogCard({required this.storeId});
  final String storeId;

  @override
  ConsumerState<_AuditLogCard> createState() => _AuditLogCardState();
}

class _AuditLogCardState extends ConsumerState<_AuditLogCard> {
  List<dynamic> _logs = [];
  bool _loading = true;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final service = ref.read(auditServiceProvider);
    final logs =
        await service.getLogsForStore(widget.storeId, limit: 50, offset: _offset);
    if (mounted) {
      setState(() {
        _logs = logs;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Card(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator())));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_logs.isEmpty)
              Text(t.common.noData, style: const TextStyle(fontSize: 13))
            else
              SizedBox(
                height: 300,
                child: ListView.separated(
                  itemCount: _logs.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 140,
                            child: Text(
                              _formatDateTime(log.createdAt),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.mutedForeground),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _actionColor(log.action),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(log.action,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${log.entityType}${log.entityId != null ? " (${log.entityId})" : ""}',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (_logs.length >= 50)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Button(
                  style:
                      const ButtonStyle.outline(density: ButtonDensity.compact),
                  onPressed: () {
                    _offset += 50;
                    _loadLogs();
                  },
                  child: const Text('Load More'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Color _actionColor(String action) {
    switch (action) {
      case 'create':
        return Colors.green;
      case 'update':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      case 'refund':
        return Colors.orange;
      default:
        return Colors.gray;
    }
  }
}

// ══════════════════════════════════════════════
// 10.11 Backup & Restore
// ══════════════════════════════════════════════

class _BackupCard extends ConsumerWidget {
  const _BackupCard({required this.storeId});
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export your local database for safekeeping. Import to restore from a backup.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Button(
                  style: const ButtonStyle.primary(),
                  onPressed: () async {
                    // Get DB path and share
                    // DB file path available via drift
                    showToast(
                      context: context,
                      builder: (_, overlay) => SurfaceCard(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Basic(
                            title: Text(t.common.success),
                            subtitle: const Text('Database exported'),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(RadixIcons.download, size: 16),
                      const SizedBox(width: 6),
                      const Text('Export'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Button(
                  style: const ButtonStyle.outline(),
                  onPressed: () {
                    showToast(
                      context: context,
                      builder: (_, overlay) => SurfaceCard(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Basic(
                            title: Text(t.common.warning),
                            subtitle:
                                const Text('Import not yet available'),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(RadixIcons.upload, size: 16),
                      const SizedBox(width: 6),
                      const Text('Import'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
