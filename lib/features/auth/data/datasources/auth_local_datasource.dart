import 'package:flutter_login_google/core/storage/secure_storage_keys.dart';
import 'package:flutter_login_google/core/storage/secure_storage_service.dart';

abstract class AuthLocalDataSource {
  Future<void> setPersistLogin(bool value);
  Future<bool> getPersistLogin();
  Future<void> clearPersistLogin();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({required SecureStorageService storage})
      : _storage = storage;

  final SecureStorageService _storage;

  @override
  Future<void> setPersistLogin(bool value) async {
    await _storage.writeBool(SecureStorageKeys.persistLogin, value);
  }

  @override
  Future<bool> getPersistLogin() async {
    // Default to false so first launch always starts at login.
    return _storage.readBool(
      SecureStorageKeys.persistLogin,
      defaultValue: false,
    );
  }

  @override
  Future<void> clearPersistLogin() async {
    await _storage.delete(SecureStorageKeys.persistLogin);
  }
}

