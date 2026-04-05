import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/sales/presentation/sales_screen.dart';
import '../../features/items/presentation/items_screen.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/customers/presentation/customers_screen.dart';
import '../../features/employees/presentation/employees_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/shifts/presentation/shifts_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/sales',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/sales',
          name: 'sales',
          builder: (context, state) => const SalesScreen(),
        ),
        GoRoute(
          path: '/items',
          name: 'items',
          builder: (context, state) => const ItemsScreen(),
        ),
        GoRoute(
          path: '/inventory',
          name: 'inventory',
          builder: (context, state) => const InventoryScreen(),
        ),
        GoRoute(
          path: '/customers',
          name: 'customers',
          builder: (context, state) => const CustomersScreen(),
        ),
        GoRoute(
          path: '/employees',
          name: 'employees',
          builder: (context, state) => const EmployeesScreen(),
        ),
        GoRoute(
          path: '/shifts',
          name: 'shifts',
          builder: (context, state) => const ShiftsScreen(),
        ),
        GoRoute(
          path: '/reports',
          name: 'reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
