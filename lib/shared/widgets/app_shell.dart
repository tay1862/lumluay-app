import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../core/constants/app_constants.dart';

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
  _NavItem(label: 'Items', icon: RadixIcons.cube, path: '/items'),
  _NavItem(label: 'Inventory', icon: RadixIcons.archive, path: '/inventory'),
  _NavItem(label: 'Customers', icon: RadixIcons.person, path: '/customers'),
  _NavItem(label: 'Employees', icon: RadixIcons.idCard, path: '/employees'),
  _NavItem(label: 'Shifts', icon: RadixIcons.clock, path: '/shifts'),
  _NavItem(label: 'Reports', icon: RadixIcons.barChart, path: '/reports'),
  _NavItem(label: 'Settings', icon: RadixIcons.gear, path: '/settings'),
];

class AppShell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.desktopBreakpoint;
    final isTablet = width >= AppConstants.tabletBreakpoint && !isDesktop;
    final currentIndex = _currentIndex(context);

    if (isDesktop) {
      return _DesktopShell(
        currentIndex: currentIndex,
        onNavTap: (i) => _onNavTap(context, i),
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
// DESKTOP: Full sidebar with labels
// ============================================================

class _DesktopShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavTap;
  final Widget child;

  const _DesktopShell({
    required this.currentIndex,
    required this.onNavTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 220,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: theme.colorScheme.border,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(RadixIcons.home, size: 24, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        AppConstants.appName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: _navItems.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    itemBuilder: (context, index) {
                      final item = _navItems[index];
                      final isSelected = index == currentIndex;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Button(
                          style: isSelected
                              ? const ButtonStyle.secondary(density: ButtonDensity.comfortable)
                              : const ButtonStyle.ghost(density: ButtonDensity.comfortable),
                          onPressed: () => onNavTap(index),
                          child: Row(
                            children: [
                              Icon(item.icon, size: 18),
                              const SizedBox(width: 10),
                              Text(item.label),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

// ============================================================
// TABLET: Narrow sidebar with icons only
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
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: theme.colorScheme.border,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Icon(RadixIcons.home, size: 24, color: theme.colorScheme.primary),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: _navItems.length,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemBuilder: (context, index) {
                      final item = _navItems[index];
                      final isSelected = index == currentIndex;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        child: IconButton.ghost(
                          icon: Icon(
                            item.icon,
                            size: 20,
                            color: isSelected ? theme.colorScheme.primary : null,
                          ),
                          onPressed: () => onNavTap(index),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

// ============================================================
// MOBILE: Bottom navigation with buttons
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
    final theme = Theme.of(context);
    const mobileIndices = [0, 1, 6, 7]; // Sales, Items, Reports, Settings

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: child),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.border,
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: mobileIndices.map((i) {
                  final item = _navItems[i];
                  final isSelected = i == currentIndex;
                  return GestureDetector(
                    onTap: () => onNavTap(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 22,
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.mutedForeground,
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
