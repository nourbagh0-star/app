part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// Authenticated user whose role has been confirmed as 'customer'.
class AuthCustomer extends AuthState {
  final User user;
  AuthCustomer(this.user);
}

/// Authenticated user whose role has been confirmed as 'barber'.
class AuthBarber extends AuthState {
  final User user;
  AuthBarber(this.user);
}

/// Authenticated user but their Firestore profile is missing/incomplete.
class AuthNeedsProfileCompletion extends AuthState {
  final User user;
  AuthNeedsProfileCompletion(this.user);
}

/// Legacy alias — kept so existing code referencing AuthAuthenticated keeps compiling.
/// Prefer using [AuthCustomer] or [AuthBarber] for new code.
class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
