import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
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

class _PinScreenState extends ConsumerState<PinScreen>
    with TickerProviderStateMixin {
  String _pin = '';
  String? _error;
  bool _loading = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));
    _fadeCtrl.forward();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_pin.length >= AppConstants.pinLength) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length == AppConstants.pinLength) _submit();
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = null;
    });
  }

  void _onClear() => setState(() {
        _pin = '';
        _error = null;
      });

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
      _shakeCtrl.forward(from: 0);
      setState(() {
        _error = errorMsg;
        _pin = '';
        _loading = false;
      });
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, min(2, name.length)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      child: Container(
        decoration: const BoxDecoration(gradient: AppTheme.softGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: SizedBox(
                width: 340,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Avatar ──
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _initials(widget.employeeName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.employeeName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.auth.enterPin,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                    const SizedBox(height: 32),

                    // ── PIN Dots with shake ──
                    AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (context, child) {
                        final dx = sin(_shakeAnim.value * pi * 4) * 12 * (1 - _shakeAnim.value);
                        return Transform.translate(offset: Offset(dx, 0), child: child);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(AppConstants.pinLength, (i) {
                          final filled = i < _pin.length;
                          final hasError = _error != null;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutBack,
                              width: filled ? 20 : 16,
                              height: filled ? 20 : 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: filled
                                    ? (hasError
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF3B82F6))
                                    : Colors.transparent,
                                border: Border.all(
                                  color: hasError
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFFBFDBFE),
                                  width: 2.5,
                                ),
                                boxShadow: filled
                                    ? [
                                        BoxShadow(
                                          color: (hasError
                                                  ? const Color(0xFFEF4444)
                                                  : const Color(0xFF3B82F6))
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Error ──
                    SizedBox(
                      height: 24,
                      child: AnimatedOpacity(
                        opacity: _error != null ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _error ?? '',
                          style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Numpad ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: _buildNumpad(),
                    ),

                    const SizedBox(height: 20),
                    Button(
                      style: const ButtonStyle.ghost(),
                      onPressed: () => context.pop(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(RadixIcons.arrowLeft, size: 16),
                          const SizedBox(width: 6),
                          Text(t.common.back),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
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
              final isAction = key == 'C' || key == '⌫';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: SizedBox(
                  width: 76,
                  height: 58,
                  child: Button(
                    style: isAction
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: isAction ? FontWeight.w500 : FontWeight.w600,
                      ),
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
