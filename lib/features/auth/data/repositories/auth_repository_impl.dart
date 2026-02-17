import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter_login_google/core/error/error_mapper.dart';
import 'package:flutter_login_google/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_login_google/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_login_google/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_login_google/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_login_google/features/auth/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final user = await _remoteDataSource.signInWithGoogle();
      if (user != null) {
        // Persist choice: keep session across restarts
        await _localDataSource.setPersistLogin(true);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw ErrorMapper.mapExceptionToFailure(e);
    } on GoogleSignInException catch (e) {
      // Don't throw for cancellation - return null
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      throw ErrorMapper.mapExceptionToFailure(e);
    } catch (e) {
      throw ErrorMapper.mapExceptionToFailure(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
      await _localDataSource.clearPersistLogin();
    } catch (e) {
      throw ErrorMapper.mapExceptionToFailure(e);
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges =>
      _remoteDataSource.authStateChanges.map(_userToEntity);
}

UserEntity? _userToEntity(User? user) {
  if (user == null) return null;
  return UserModel(
    uid: user.uid,
    email: user.email ?? '',
    displayName: user.displayName,
    photoUrl: user.photoURL,
  );
}
