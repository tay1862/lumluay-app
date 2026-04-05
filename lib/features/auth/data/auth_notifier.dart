import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audit/audit_service.dart';
import '../../../core/logging/app_logger.dart';
import 'auth_repository.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  final AuditService _auditService;

  AuthNotifier(this._authRepo, this._auditService)
      : super(const AuthState.unauthenticated());

  Future<String?> login(String employeeId, String pin, String storeId) async {
    final result = await _authRepo.verifyPin(employeeId, pin);

    return result.when(
      success: (employee) {
        state = AuthState(
          currentEmployee: employee,
          currentStoreId: storeId,
          isAuthenticated: true,
        );

        _auditService.log(
          storeId: storeId,
          employeeId: employee.id,
          action: AuditAction.login,
          entityType: 'employee',
          entityId: employee.id,
        );

        AppLogger.info('Employee ${employee.name} logged in');
        return null; // no error
      },
      failure: (error) {
        AppLogger.warning('Login failed: ${error.message}');
        return error.message;
      },
    );
  }

  void logout() {
    final employee = state.currentEmployee;
    final storeId = state.currentStoreId;

    if (employee != null && storeId != null) {
      _auditService.log(
        storeId: storeId,
        employeeId: employee.id,
        action: AuditAction.logout,
        entityType: 'employee',
        entityId: employee.id,
      );
      AppLogger.info('Employee ${employee.name} logged out');
    }

    state = const AuthState.unauthenticated();
  }

  void switchStore(String storeId) {
    state = state.copyWith(currentStoreId: storeId);
  }
}
