import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../i18n/strings.g.dart';
import '../../employees/data/employee_providers.dart';
import '../../settings/data/settings_providers.dart';

// ── Avatar Colors ──
const _avatarColors = [
  Color(0xFF3B82F6),
  Color(0xFF06B6D4),
  Color(0xFF8B5CF6),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
  Color(0xFFEC4899),
  Color(0xFF14B8A6),
];

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedStoreId;
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final storesAsync = ref.watch(allStoresStreamProvider);

    return Scaffold(
      child: Container(
        decoration: const BoxDecoration(gradient: AppTheme.softGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: SizedBox(
                  width: 440,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Logo ──
                      _AnimatedLogo(),
                      const SizedBox(height: 12),
                      const Text(
                        'Lumluay POS',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.auth.selectEmployee,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Main Card ──
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: storesAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                          error: (e, _) => Text('Error: $e'),
                          data: (stores) {
                            if (stores.isEmpty) {
                              return _InitialSetup(
                                onSetupComplete: (storeId) {
                                  setState(() => _selectedStoreId = storeId);
                                },
                              );
                            }

                            final storeId =
                                _selectedStoreId ?? stores.first.id;
                            if (_selectedStoreId == null) {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() =>
                                      _selectedStoreId = stores.first.id);
                                }
                              });
                            }

                            return Column(
                              children: [
                                if (stores.length > 1) ...[
                                  Select<String>(
                                    value: storeId,
                                    onChanged: (v) =>
                                        setState(() => _selectedStoreId = v),
                                    itemBuilder: (context, item) => Text(
                                      stores
                                          .firstWhere((s) => s.id == item)
                                          .name,
                                    ),
                                    popup: (_) => SelectPopup(
                                      items: SelectItemList(
                                        children: stores
                                            .map((s) =>
                                                SelectItemButton<String>(
                                                  value: s.id,
                                                  child: Text(s.name),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                                _EmployeeGrid(storeId: storeId),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated bouncing logo ──
class _AnimatedLogo extends StatefulWidget {
  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _bounce.value),
        child: child,
      ),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '☕',
            style: TextStyle(fontSize: 36),
          ),
        ),
      ),
    );
  }
}

// ── Initial Setup Widget ──
class _InitialSetup extends ConsumerStatefulWidget {
  final ValueChanged<String> onSetupComplete;
  const _InitialSetup({required this.onSetupComplete});

  @override
  ConsumerState<_InitialSetup> createState() => _InitialSetupState();
}

class _InitialSetupState extends ConsumerState<_InitialSetup> {
  final _storeNameController = TextEditingController(text: 'My Store');
  final _employeeNameController = TextEditingController(text: 'Admin');
  final _pinController = TextEditingController(text: '1234');
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _storeNameController.dispose();
    _employeeNameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _createStoreAndEmployee() async {
    final storeName = _storeNameController.text.trim();
    final employeeName = _employeeNameController.text.trim();
    final pin = _pinController.text.trim();

    if (storeName.isEmpty || employeeName.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    if (pin.length < 4) {
      setState(() => _error = 'PIN must be at least 4 digits');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final storeRepo = ref.read(storeRepositoryProvider);
      final employeeRepo = ref.read(employeeRepositoryProvider);
      final store = await storeRepo.createStore(name: storeName);
      final result = await employeeRepo.createEmployee(
        storeId: store.id,
        name: employeeName,
        pin: pin,
      );

      result.when(
        success: (_) => widget.onSetupComplete(store.id),
        failure: (error) {
          setState(() {
            _error = error.message;
            _loading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Setup failed: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(RadixIcons.rocket, color: Color(0xFF3B82F6), size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Quick Setup',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Create your first store and employee to get started.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
        const SizedBox(height: 20),

        _fieldLabel('Store Name'),
        TextField(
          controller: _storeNameController,
          placeholder: const Text('e.g. My Coffee Shop'),
        ),
        const SizedBox(height: 14),

        _fieldLabel('Your Name'),
        TextField(
          controller: _employeeNameController,
          placeholder: const Text('e.g. Somchai'),
        ),
        const SizedBox(height: 14),

        _fieldLabel('Login PIN'),
        TextField(
          controller: _pinController,
          placeholder: const Text('4-digit PIN'),
          obscureText: true,
        ),
        const SizedBox(height: 6),
        const Text(
          'You will use this PIN to log in.',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),

        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
        ],

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: Button(
            style: const ButtonStyle.primary(density: ButtonDensity.comfortable),
            onPressed: _loading ? null : _createStoreAndEmployee,
            child: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(RadixIcons.rocket, size: 16),
                      SizedBox(width: 8),
                      Text('Create & Start'),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
      ),
    );
  }
}

// ── Employee Grid ──
class _EmployeeGrid extends ConsumerWidget {
  final String storeId;
  const _EmployeeGrid({required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesProvider(storeId));

    return employeesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ),
      error: (e, _) => Text('Error: $e'),
      data: (employees) {
        final active = employees.where((e) => e.employee.active).toList();

        if (active.isEmpty) {
          return const Text(
            'No active employees.',
            style: TextStyle(color: Color(0xFF94A3B8)),
          );
        }

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: active.asMap().entries.map((entry) {
            final i = entry.key;
            final ew = entry.value;
            final emp = ew.employee;
            final color = _avatarColors[i % _avatarColors.length];

            return _EmployeeCard(
              name: emp.name,
              roleName: ew.roleName,
              color: color,
              delay: Duration(milliseconds: 80 * i),
              onTap: () {
                context.pushNamed(
                  'pin',
                  pathParameters: {'employeeId': emp.id},
                  extra: {'employeeName': emp.name, 'storeId': storeId},
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

// ── Employee Card with staggered animation ──
class _EmployeeCard extends StatefulWidget {
  final String name;
  final String? roleName;
  final Color color;
  final Duration delay;
  final VoidCallback onTap;

  const _EmployeeCard({
    required this.name,
    this.roleName,
    required this.color,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<_EmployeeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, min(2, name.length)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.scale(scale: _scale.value, child: child),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 110,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            decoration: BoxDecoration(
              color: _hovering ? widget.color.withValues(alpha: 0.06) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hovering ? widget.color.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
              ),
              boxShadow: _hovering
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _hovering ? 48 : 44,
                  height: _hovering ? 48 : 44,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _initials(widget.name),
                      style: TextStyle(
                        color: widget.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.name,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.roleName != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    widget.roleName!,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
