import 'package:flutter_login_google/features/auth/domain/entities/user_entity.dart';

/// Abstract auth repository contract.
abstract class AuthRepository {
  Future<UserEntity?> signInWithGoogle();
  Future<void> signOut();
  Stream<UserEntity?> get authStateChanges;
}
