import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_login_google/core/constants/route_constants.dart';
import 'package:flutter_login_google/core/constants/string_constants.dart';
import 'package:flutter_login_google/core/constants/ui_constants.dart';
import 'package:flutter_login_google/core/di/service_locator.dart';
import 'package:flutter_login_google/core/widgets/error_banner.dart';
import 'package:flutter_login_google/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_login_google/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_login_google/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_login_google/features/posts/presentation/bloc/post_bloc.dart';
import 'package:flutter_login_google/features/posts/presentation/pages/post_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(RouteConstants.login);
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          // Show posts page right after sign-in
          final userName = (state.user.displayName?.trim().isNotEmpty ?? false)
              ? state.user.displayName!.trim()
              : state.user.email;
          return BlocProvider(
            create: (_) => sl<PostBloc>(),
            child: PostPage(
              userName: userName,
              onLogout: () {
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
            ),
          );
        }

        // Show error banner if error state (e.g., sign-out error)
        if (state is AuthError) {
          return Scaffold(
            appBar: AppBar(title: const Text(StringConstants.home)),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: ErrorBanner(
                    message: state.message,
                    errorType: _mapErrorType(state.errorType),
                    canRetry: state.canRetry,
                    onRetry: state.canRetry
                        ? () => context.read<AuthBloc>().add(
                              const AuthSignOutRequested(),
                            )
                        : null,
                    onDismiss: () {
                      context.read<AuthBloc>().add(
                            const AuthCheckRequested(),
                          );
                    },
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          );
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
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
