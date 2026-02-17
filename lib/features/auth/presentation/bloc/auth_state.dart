import 'package:equatable/equatable.dart';

import 'package:flutter_login_google/features/auth/domain/entities/user_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthState {
  const AuthError(
    this.message, {
    this.errorType,
    this.canRetry = false,
  });

  final String message;
  final AuthErrorType? errorType;
  final bool canRetry;

  @override
  List<Object?> get props => [message, errorType, canRetry];
}

enum AuthErrorType {
  network,
  authentication,
  server,
  unknown,
}
