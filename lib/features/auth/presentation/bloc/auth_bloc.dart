import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_login_google/core/error/error_mapper.dart';
import 'package:flutter_login_google/core/error/failure.dart';
import 'package:flutter_login_google/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:flutter_login_google/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter_login_google/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_login_google/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SignInWithGoogle signInWithGoogle,
    required SignOut signOut,
  })  : _signInWithGoogle = signInWithGoogle,
        _signOut = signOut,
        super(const AuthInitial()) {
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSetUser>(_onSetUser);
  }

  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;

  Future<void> _onSignInWithGoogleRequested(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _signInWithGoogle();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        // User cancelled - don't show error, just go back to unauthenticated
        emit(const AuthUnauthenticated());
      }
    } on Failure catch (failure, st) {
      // Don't show error for cancellation
      if (failure is CancellationFailure) {
        emit(const AuthUnauthenticated());
      } else {
        if (kDebugMode) {
          debugPrint(
            '[AuthBloc] Sign-in failed: ${failure.runtimeType}: ${failure.message}',
          );
          debugPrint(st.toString());
        }
        emit(_mapFailureToAuthError(failure));
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[AuthBloc] Sign-in threw: $e');
        debugPrint(st.toString());
      }
      final failure = ErrorMapper.mapExceptionToFailure(e);
      emit(_mapFailureToAuthError(failure));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _signOut();
      emit(const AuthUnauthenticated());
    } on Failure catch (failure) {
      emit(_mapFailureToAuthError(failure));
    } catch (e) {
      final failure = ErrorMapper.mapExceptionToFailure(e);
      emit(_mapFailureToAuthError(failure));
    }
  }

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthInitial());
  }

  void _onSetUser(AuthSetUser event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Maps Failure to AuthError with appropriate error type and retry flag.
  AuthError _mapFailureToAuthError(Failure failure) {
    AuthErrorType errorType;
    bool canRetry = false;

    if (failure is NetworkFailure) {
      errorType = AuthErrorType.network;
      canRetry = true; // Network errors can be retried
    } else if (failure is AuthFailure) {
      errorType = AuthErrorType.authentication;
      canRetry = true; // Auth errors can be retried
    } else if (failure is ServerFailure) {
      errorType = AuthErrorType.server;
      canRetry = true; // Server errors can be retried
    } else {
      errorType = AuthErrorType.unknown;
      canRetry = false; // Unknown errors shouldn't be retried
    }

    return AuthError(
      ErrorMapper.getErrorMessage(failure),
      errorType: errorType,
      canRetry: canRetry,
    );
  }
}
