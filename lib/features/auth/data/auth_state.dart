import '../../../core/database/app_database.dart';

class AuthState {
  final Employee? currentEmployee;
  final String? currentStoreId;
  final bool isAuthenticated;

  const AuthState({
    this.currentEmployee,
    this.currentStoreId,
    this.isAuthenticated = false,
  });

  const AuthState.unauthenticated()
      : currentEmployee = null,
        currentStoreId = null,
        isAuthenticated = false;

  AuthState copyWith({
    Employee? currentEmployee,
    String? currentStoreId,
    bool? isAuthenticated,
  }) {
    return AuthState(
      currentEmployee: currentEmployee ?? this.currentEmployee,
      currentStoreId: currentStoreId ?? this.currentStoreId,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}
