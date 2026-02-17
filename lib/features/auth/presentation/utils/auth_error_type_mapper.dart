import 'package:flutter_login_google/core/widgets/error_banner.dart';
import 'package:flutter_login_google/features/auth/presentation/bloc/auth_state.dart';

/// Maps authentication error types to UI `ErrorType` used by [ErrorBanner].
ErrorType? mapAuthErrorTypeToErrorType(AuthErrorType? type) {
  if (type == null) return null;
  switch (type) {
    case AuthErrorType.network:
      return ErrorType.network;
    case AuthErrorType.authentication:
      return ErrorType.authentication;
    case AuthErrorType.server:
      return ErrorType.server;
    case AuthErrorType.unknown:
      return ErrorType.unknown;
  }
}

