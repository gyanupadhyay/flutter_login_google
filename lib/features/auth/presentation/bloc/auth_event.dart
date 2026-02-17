import 'package:equatable/equatable.dart';

import 'package:flutter_login_google/features/auth/domain/entities/user_entity.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthSignInWithGoogleRequested extends AuthEvent {
  const AuthSignInWithGoogleRequested();
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

final class AuthSetUser extends AuthEvent {
  const AuthSetUser(this.user);

  final UserEntity? user;

  @override
  List<Object?> get props => [user];
}
