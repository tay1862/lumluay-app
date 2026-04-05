import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../i18n/strings.g.dart';

class PinScreen extends ConsumerStatefulWidget {
  final String employeeId;
  final String employeeName;
  final String storeId;

  const PinScreen({
    super.key,
    required this.employeeId,
    required this.employeeName,
    required this.storeId,
  });

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  String _pin = '';
  String? _error;
  bool _loading = false;

  void _onDigit(String digit) {
    if (_pin.length >= AppConstants.pinLength) return;
    setState(() {
      _pin += digit;
      _error = null;
    });

    if (_pin.length == AppConstants.pinLength) {
      _submit();
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = null;
    });
  }

  void _onClear() {
    setState(() {
      _pin = '';
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _loading = true);

    final errorMsg = await ref.read(authProvider.notifier).login(
          widget.employeeId,
          _pin,
          widget.storeId,
        );

    if (!mounted) return;

    if (errorMsg != null) {
      setState(() {
        _error = errorMsg;
        _pin = '';
        _loading = false;
      });
    }
    // If success, authProvider state changes and router redirects
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      child: Center(
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                RadixIcons.person,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                widget.employeeName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.auth.enterPin,
                style: TextStyle(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 32),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(AppConstants.pinLength, (i) {
                  final filled = i < _pin.length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: _error != null
                              ? theme.colorScheme.destructive
                              : theme.colorScheme.border,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),

              // Error message
              SizedBox(
                height: 24,
                child: _error != null
                    ? Text(
                        _error!,
                        style: TextStyle(
                          color: theme.colorScheme.destructive,
                          fontSize: 13,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Number pad
              _buildNumpad(theme),

              const SizedBox(height: 24),
              Button(
                style: const ButtonStyle.ghost(),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(t.common.back),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad(ThemeData theme) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['C', '0', '⌫'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: SizedBox(
                  width: 72,
                  height: 56,
                  child: Button(
                    style: key == 'C' || key == '⌫'
                        ? const ButtonStyle.outline()
                        : const ButtonStyle.secondary(),
                    onPressed: _loading
                        ? null
                        : () {
                            if (key == '⌫') {
                              _onBackspace();
                            } else if (key == 'C') {
                              _onClear();
                            } else {
                              _onDigit(key);
                            }
                          },
                    child: Text(
                      key,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
