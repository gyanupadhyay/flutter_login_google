import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_login_google/core/constants/route_constants.dart';
import 'package:flutter_login_google/core/constants/string_constants.dart';
import 'package:flutter_login_google/core/constants/ui_constants.dart';
import 'package:flutter_login_google/core/widgets/error_banner.dart';
import 'package:flutter_login_google/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_login_google/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_login_google/features/auth/presentation/bloc/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(RouteConstants.home, extra: state.user);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Column(
              children: [
                // Error banner at the top (if error exists)
                if (state is AuthError)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: ErrorBanner(
                      message: state.message,
                      errorType: _mapErrorType(state.errorType),
                      canRetry: state.canRetry,
                      onRetry: state.canRetry
                          ? () => context.read<AuthBloc>().add(
                                const AuthSignInWithGoogleRequested(),
                              )
                          : null,
                      onDismiss: () {
                        // Dismiss error by emitting unauthenticated state
                        context.read<AuthBloc>().add(
                              const AuthCheckRequested(),
                            );
                      },
                    ),
                  ),
                // Main content
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: AppInsets.loginContent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            StringConstants.welcome,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            StringConstants.signInWithGoogleToContinue,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          FilledButton.icon(
                            onPressed: () => context.read<AuthBloc>().add(
                                  const AuthSignInWithGoogleRequested(),
                                ),
                            icon: const Icon(Icons.login),
                            label: const Text(StringConstants.signInWithGoogle),
                            style: FilledButton.styleFrom(
                              padding: AppInsets.primaryButton,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  ErrorType? _mapErrorType(AuthErrorType? type) {
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
}
