import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../constants/string_constants.dart';
import 'failure.dart';

/// Maps exceptions to user-friendly error messages.
class ErrorMapper {
  ErrorMapper._();

  /// Maps an exception to a Failure with user-friendly message.
  static Failure mapExceptionToFailure(Object exception) {
    if (exception is FirebaseAuthException) {
      return _mapFirebaseAuthException(exception);
    }

    if (exception is GoogleSignInException) {
      return _mapGoogleSignInException(exception);
    }

    if (exception is http.ClientException) {
      return NetworkFailure(StringConstants.networkError);
    }

    if (exception is ServerFailure) {
      return exception;
    }

    if (exception is NetworkException) {
      return NetworkFailure(StringConstants.networkError);
    }

    // Check for common network-related error messages
    final errorMessage = exception.toString().toLowerCase();
    if (errorMessage.contains('network') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('internet') ||
        errorMessage.contains('socket')) {
      return NetworkFailure(StringConstants.networkError);
    }

    return UnknownFailure(StringConstants.unknownError);
  }

  /// Maps Firebase Auth exceptions to user-friendly messages.
  static Failure _mapFirebaseAuthException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'network-request-failed':
        return NetworkFailure(StringConstants.networkError);
      case 'user-disabled':
        return AuthFailure(StringConstants.userDisabled);
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return AuthFailure(StringConstants.invalidCredentials);
      case 'too-many-requests':
        return AuthFailure(StringConstants.tooManyRequests);
      case 'operation-not-allowed':
        return AuthFailure(StringConstants.operationNotAllowed);
      case 'account-exists-with-different-credential':
        return AuthFailure(StringConstants.accountExistsWithDifferentCredential);
      default:
        return AuthFailure(
          exception.message ?? StringConstants.signInFailed,
        );
    }
  }

  /// Maps Google Sign-In exceptions to user-friendly messages.
  static Failure _mapGoogleSignInException(GoogleSignInException exception) {
    switch (exception.code) {
      case GoogleSignInExceptionCode.canceled:
        return CancellationFailure(StringConstants.signInCancelled);
      case GoogleSignInExceptionCode.interrupted:
        // Check if it's a network-related interruption
        final description = exception.description?.toLowerCase() ?? '';
        if (description.contains('network') ||
            description.contains('connection') ||
            description.contains('internet')) {
          return NetworkFailure(StringConstants.networkError);
        }
        return AuthFailure(StringConstants.signInFailed);
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return AuthFailure(
          exception.description ?? StringConstants.operationNotAllowed,
        );
      case GoogleSignInExceptionCode.uiUnavailable:
        return AuthFailure(StringConstants.signInFailed);
      case GoogleSignInExceptionCode.userMismatch:
        return AuthFailure(StringConstants.signInFailed);
      case GoogleSignInExceptionCode.unknownError:
        // Check exception description for network-related errors
        final description = exception.description?.toLowerCase() ?? '';
        if (description.contains('network') ||
            description.contains('connection') ||
            description.contains('internet')) {
          return NetworkFailure(StringConstants.networkError);
        }
        return AuthFailure(
          exception.description ?? StringConstants.signInFailed,
        );
    }
  }

  /// Gets user-friendly error message from failure.
  static String getErrorMessage(Failure failure) {
    return failure.message;
  }
}

/// Network exception class for network-related errors.
class NetworkException implements Exception {
  NetworkException(this.message);
  final String message;
}
