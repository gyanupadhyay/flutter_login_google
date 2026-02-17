import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> writeBool(String key, bool value) async {
    try {
      await _storage.write(key: key, value: value ? 'true' : 'false');
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[SecureStorage] writeBool failed for key=$key: $e');
        debugPrint(st.toString());
      }
      rethrow;
    }
  }

  Future<bool> readBool(String key, {bool defaultValue = false}) async {
    try {
      final value = await _storage.read(key: key);
      if (value == null) return defaultValue;
      return value.toLowerCase() == 'true';
    } catch (e, st) {
      // If secure storage fails, don't accidentally log the user out.
      if (kDebugMode) {
        debugPrint('[SecureStorage] readBool failed for key=$key: $e');
        debugPrint(st.toString());
      }
      return defaultValue;
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[SecureStorage] delete failed for key=$key: $e');
        debugPrint(st.toString());
      }
      rethrow;
    }
  }
}

