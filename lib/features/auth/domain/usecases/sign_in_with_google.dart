import 'package:flutter_login_google/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_login_google/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogle {
  SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<UserEntity?> call() => _repository.signInWithGoogle();
}
