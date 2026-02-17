import 'dart:ui';

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
import 'package:flutter_login_google/features/auth/presentation/utils/auth_error_type_mapper.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(RouteConstants.home, extra: state.user);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.6),
                      colorScheme.secondary.withValues(alpha: 0.4),
                      colorScheme.surfaceVariant.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
              // Subtle blurred overlay to enhance glass effect
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: colorScheme.surface.withValues(alpha: 0.1),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    // Error banner at the top (if error exists)
                    if (state is AuthError)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.lg),
                        child: ErrorBanner(
                          message: state.message,
                          errorType:
                              mapAuthErrorTypeToErrorType(state.errorType),
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
                    // Main glass card content
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: AppInsets.loginContent,
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppRadii.lg),
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withValues(
                                  alpha: 0.25,
                                ),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.lg),
                                border: Border.all(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.12,
                                  ),
                                  width: 1.2,
                                ),
                              ),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 28,
                                  sigmaY: 28,
                                ),
                                child: Padding(
                                  padding: AppInsets.card,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        StringConstants.welcome,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              color: colorScheme.onSurface,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        StringConstants
                                            .signInWithGoogleToContinue,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: AppSpacing.xxxl),
                                      FilledButton.icon(
                                        onPressed: isLoading
                                            ? null
                                            : () => context
                                                    .read<AuthBloc>()
                                                .add(
                                              const AuthSignInWithGoogleRequested(),
                                            ),
                                        style: FilledButton.styleFrom(
                                          padding: AppInsets.primaryButton,
                                        ),
                                        icon: const Icon(Icons.login),
                                        label: const Text(
                                          StringConstants.signInWithGoogle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Loading overlay
              if (isLoading)
                Container(
                  color: colorScheme.surface.withValues(alpha: 0.2),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
