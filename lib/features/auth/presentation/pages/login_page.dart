import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_login_google/core/constants/app_colors.dart';
import 'package:flutter_login_google/core/constants/app_typography.dart';
import 'package:flutter_login_google/core/constants/route_constants.dart';
import 'package:flutter_login_google/core/constants/string_constants.dart';
import 'package:flutter_login_google/core/constants/ui_constants.dart';
import 'package:flutter_login_google/core/widgets/error_banner.dart';
import 'package:flutter_login_google/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_login_google/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_login_google/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_login_google/features/auth/presentation/utils/auth_error_type_mapper.dart';
import 'package:flutter_login_google/features/auth/presentation/widgets/login_options_sheet.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey _continueButtonKey = GlobalKey();

  Future<void> _openLoginSheet() async {
    final renderObject = _continueButtonKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;

    final buttonOffset = renderObject.localToGlobal(Offset.zero);
    final buttonRect = buttonOffset & renderObject.size;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 80),
      pageBuilder: (dialogContext, _, _) {
        final size = MediaQuery.sizeOf(dialogContext);
        final bottomGap = (size.height - buttonRect.bottom).clamp(
          0.0,
          size.height,
        );
        final rightGap = (size.width - buttonRect.right).clamp(0.0, size.width);

        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(dialogContext).pop(),
                  child: const SizedBox.shrink(),
                ),
              ),
              Positioned(
                left: buttonRect.left,
                right: rightGap,
                bottom: bottomGap,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: LoginOptionsSheet(
                    onEmail: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email login not implemented yet.'),
                        ),
                      );
                    },
                    onApple: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Apple login not implemented yet.'),
                        ),
                      );
                    },
                    onGoogle: () {
                      Navigator.of(dialogContext).pop();
                      context.read<AuthBloc>().add(
                        const AuthSignInWithGoogleRequested(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, _, child) => child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(RouteConstants.home, extra: state.user);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
            children: [
              const ColoredBox(color: AppColors.loginBackground),
              SafeArea(
                child: Column(
                  children: [
                    if (state is AuthError)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.lg,
                          left: AppSpacing.lg,
                          right: AppSpacing.lg,
                        ),
                        child: ErrorBanner(
                          message: state.message,
                          errorType: mapAuthErrorTypeToErrorType(
                            state.errorType,
                          ),
                          canRetry: state.canRetry,
                          onRetry: state.canRetry
                              ? () => context.read<AuthBloc>().add(
                                  const AuthSignInWithGoogleRequested(),
                                )
                              : null,
                          onDismiss: () {
                            context.read<AuthBloc>().add(
                              const AuthCheckRequested(),
                            );
                          },
                        ),
                      ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Align(
                            alignment: const Alignment(0, 0.07),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    StringConstants.loginHeroTitle,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.loginHeroTitle,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    StringConstants.loginHeroSubtitle,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.loginHeroSubtitle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: SafeArea(
                        top: false,
                        child: SizedBox(
                          key: _continueButtonKey,
                          width: double.infinity,
                          height: 56,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.neumorphicSurface,
                              borderRadius: BorderRadius.circular(AppRadii.xxl),
                              border: Border.all(
                                color: AppColors.neumorphicBorder,
                                width: 2,
                              ),
                              boxShadow: const [
                                // Soft top highlight (approximate inner light)
                                BoxShadow(
                                  color: AppColors.neumorphicHighlight,
                                  offset: Offset(0, -3),
                                  blurRadius: 4,
                                ),
                                // Soft bottom shade (approximate inner dark)
                                BoxShadow(
                                  color: AppColors.neumorphicShade,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                                // Main drop shadow
                                BoxShadow(
                                  color: AppColors.neumorphicShadow,
                                  offset: Offset(0, 4),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(AppRadii.xxl),
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.xxl),
                                onTap: isLoading ? null : _openLoginSheet,
                                child: const Center(
                                  child: Text(
                                    StringConstants.loginCtaContinue,
                                    style: AppTypography.primaryCta,
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
              if (isLoading)
                Container(
                  color: colorScheme.surface.withValues(alpha: 0.2),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
