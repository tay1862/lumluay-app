import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../features/settings/data/settings_providers.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final String path;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.path,
  });
}

const _navItems = [
  _NavItem(label: 'Sales', icon: RadixIcons.desktop, path: '/sales'),
  _NavItem(label: 'Tickets', icon: RadixIcons.reader, path: '/tickets'),
  _NavItem(label: 'Items', icon: RadixIcons.cube, path: '/items'),
  _NavItem(label: 'Inventory', icon: RadixIcons.archive, path: '/inventory'),
  _NavItem(label: 'Customers', icon: RadixIcons.person, path: '/customers'),
  _NavItem(label: 'Employees', icon: RadixIcons.idCard, path: '/employees'),
  _NavItem(label: 'Shifts', icon: RadixIcons.clock, path: '/shifts'),
  _NavItem(label: 'Tables', icon: RadixIcons.home, path: '/tables'),
  _NavItem(label: 'KDS', icon: RadixIcons.timer, path: '/kds'),
  _NavItem(label: 'Reports', icon: RadixIcons.barChart, path: '/reports'),
  _NavItem(label: 'Settings', icon: RadixIcons.gear, path: '/settings'),
];

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (var i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].path)) return i;
    }
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    context.go(_navItems[index].path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.desktopBreakpoint;
    final isTablet = width >= AppConstants.tabletBreakpoint && !isDesktop;
    final currentIndex = _currentIndex(context);

    if (isDesktop) {
      return _DesktopShell(
        currentIndex: currentIndex,
        onNavTap: (i) => _onNavTap(context, i),
        ref: ref,
        child: child,
      );
    }

    if (isTablet) {
      return _TabletShell(
        currentIndex: currentIndex,
        onNavTap: (i) => _onNavTap(context, i),
        child: child,
      );
    }

    return _MobileShell(
      currentIndex: currentIndex,
      onNavTap: (i) => _onNavTap(context, i),
      child: child,
    );
  }
}

// ============================================================
// DESKTOP: Beautiful gradient sidebar with labels
// ============================================================

class _DesktopShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavTap;
  final WidgetRef ref;
  final Widget child;

  const _DesktopShell({
    required this.currentIndex,
    required this.onNavTap,
    required this.ref,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Sidebar ──
        Container(
          width: 230,
          decoration: const BoxDecoration(
            gradient: AppTheme.sidebarGradient,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Brand header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('☕', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Lumluay POS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white.withValues(alpha: 0.12),
              ),
              const SizedBox(height: 8),
              // ── Nav items ──
              Expanded(
                child: ListView.builder(
                  itemCount: _navItems.length,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  itemBuilder: (context, index) {
                    final item = _navItems[index];
                    final isSelected = index == currentIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: _SidebarButton(
                        icon: item.icon,
                        label: item.label,
                        isSelected: isSelected,
                        onTap: () => onNavTap(index),
                      ),
                    );
                  },
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white.withValues(alpha: 0.12),
              ),
              _StoreSwitcher(ref: ref),
            ],
          ),
        ),
        // ── Content ──
        Expanded(
          child: Container(
            color: const Color(0xFFF0F9FF),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _SidebarButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<_SidebarButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.white.withValues(alpha: 0.18)
                : _hovering
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: widget.isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                ),
              ),
              if (widget.isSelected) ...[
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF60A5FA),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreSwitcher extends StatelessWidget {
  final WidgetRef ref;

  const _StoreSwitcher({required this.ref});

  @override
  Widget build(BuildContext context) {
    final storesAsync = ref.watch(allStoresStreamProvider);
    final currentStoreId = ref.watch(authProvider).currentStoreId;

    return storesAsync.when(
      data: (stores) {
        if (stores.length <= 1) return const SizedBox(height: 12);
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: stores.map((store) {
              final isSelected = store.id == currentStoreId;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: GestureDetector(
                  onTap: () => ref.read(authProvider.notifier).switchStore(store.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          RadixIcons.home,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            store.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: isSelected ? 1 : 0.7),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const SizedBox(height: 12),
      error: (_, _) => const SizedBox(height: 12),
    );
  }
}

// ============================================================
// TABLET: Narrow icon sidebar with blue gradient
// ============================================================

class _TabletShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavTap;
  final Widget child;

  const _TabletShell({
    required this.currentIndex,
    required this.onNavTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 68,
          decoration: const BoxDecoration(
            gradient: AppTheme.sidebarGradient,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('☕', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: Colors.white.withValues(alpha: 0.12),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _navItems.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final item = _navItems[index];
                    final isSelected = index == currentIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      child: GestureDetector(
                        onTap: () => onNavTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.18)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              item.icon,
                              size: 20,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFFF0F9FF),
            child: child,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// MOBILE: Bottom tab bar
// ============================================================

class _MobileShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavTap;
  final Widget child;

  const _MobileShell({
    required this.currentIndex,
    required this.onNavTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const mobileIndices = [0, 2, 9, 10]; // Sales, Items, Reports, Settings

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            color: const Color(0xFFF0F9FF),
            child: child,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: mobileIndices.map((i) {
                  final item = _navItems[i];
                  final isSelected = i == currentIndex;
                  return GestureDetector(
                    onTap: () => onNavTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: isSelected ? 16 : 0,
                              vertical: isSelected ? 4 : 0,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFEFF6FF)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item.icon,
                              size: 22,
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
