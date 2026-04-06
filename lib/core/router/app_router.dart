import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/pin_screen.dart';
import '../../features/sales/presentation/sales_screen.dart';
import '../../features/sales/presentation/receipt_history_screen.dart';
import '../../features/sales/presentation/open_tickets_screen.dart';
import '../../features/sales/presentation/table_management_screen.dart';
import '../../features/sales/presentation/kds_screen.dart';
import '../../features/sales/presentation/customer_display_screen.dart';
import '../../features/items/presentation/items_screen.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/inventory/presentation/purchase_order_screen.dart';
import '../../features/inventory/presentation/transfer_screen.dart';
import '../../features/inventory/presentation/production_screen.dart';
import '../../features/customers/presentation/customers_screen.dart';
import '../../features/employees/presentation/employees_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/shifts/presentation/shifts_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../providers/auth_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/sales',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation.startsWith('/login');

      if (!isAuthenticated && !isLoginRoute) return '/login';
      if (isAuthenticated && isLoginRoute) return '/sales';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'pin/:employeeId',
            name: 'pin',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return PinScreen(
                employeeId: state.pathParameters['employeeId']!,
                employeeName: extra['employeeName'] as String,
                storeId: extra['storeId'] as String,
              );
            },
          ),
        ],
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
        GoRoute(
          path: '/sales',
          name: 'sales',
          builder: (context, state) => const SalesScreen(),
          routes: [
            GoRoute(
              path: 'receipts',
              name: 'receipts',
              builder: (context, state) => const ReceiptHistoryScreen(),
            ),
          ],
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
          routes: [
            GoRoute(
              path: 'purchase-orders',
              name: 'purchaseOrders',
              builder: (context, state) => const PurchaseOrderScreen(),
            ),
            GoRoute(
              path: 'transfers',
              name: 'transfers',
              builder: (context, state) => const TransferScreen(),
            ),
            GoRoute(
              path: 'production',
              name: 'production',
              builder: (context, state) => const ProductionScreen(),
            ),
          ],
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
        GoRoute(
          path: '/tickets',
          name: 'tickets',
          builder: (context, state) => const OpenTicketsScreen(),
        ),
        GoRoute(
          path: '/tables',
          name: 'tables',
          builder: (context, state) => const TableManagementScreen(),
        ),
        GoRoute(
          path: '/kds',
          name: 'kds',
          builder: (context, state) => const KdsScreen(),
        ),
        GoRoute(
          path: '/customer-display',
          name: 'customerDisplay',
          builder: (context, state) => const CustomerDisplayScreen(),
        ),
      ],
    ),
  ],
);
});
