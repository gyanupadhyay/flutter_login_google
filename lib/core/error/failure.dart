import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Failure for server/API errors.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Failure for network connectivity issues.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure for authentication errors.
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Failure for user cancellation.
class CancellationFailure extends Failure {
  const CancellationFailure(super.message);
}

/// Failure for unknown/unexpected errors.
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
