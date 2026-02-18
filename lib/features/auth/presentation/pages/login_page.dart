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
import 'package:flutter_login_google/features/auth/presentation/widgets/auth_option_button.dart';

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
                  child: _LoginOptionsSheet(
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
                              borderRadius: BorderRadius.circular(34),
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
                              borderRadius: BorderRadius.circular(34),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(34),
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

class _LoginOptionsSheet extends StatefulWidget {
  const _LoginOptionsSheet({
    required this.onEmail,
    required this.onApple,
    required this.onGoogle,
  });

  final VoidCallback onEmail;
  final VoidCallback onApple;
  final VoidCallback onGoogle;

  @override
  State<_LoginOptionsSheet> createState() => _LoginOptionsSheetState();
}

class _LoginOptionsSheetState extends State<_LoginOptionsSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _fade(double begin, double end) => CurvedAnimation(
    parent: _controller,
    curve: Interval(begin, end, curve: Curves.easeOutCubic),
  );

  Animation<Offset> _slide(double begin, double end) =>
      Tween<Offset>(
        // Start well below the sheet so content clearly rises from the bottom.
        begin: const Offset(0, 0.45),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(begin, end, curve: Curves.easeOutCubic),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragDistance += details.delta.dy;
          if (_dragDistance < 0) _dragDistance = 0;
        });
      },
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (_dragDistance > 80 || velocity > 700) {
          Navigator.of(context).pop();
        }
        _dragDistance = 0;
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final curveValue = CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
            ).value;
            final widthFactor = 0.3 + (0.7 * curveValue);
            final baseScale = 0.7 + (0.3 * curveValue);
            final dragProgress = (_dragDistance / 160).clamp(0.0, 1.0);
            final scale = baseScale * (1 - 0.15 * dragProgress);
            return FractionallySizedBox(
              widthFactor: widthFactor.clamp(0.3, 1.0),
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.sheetBackground,
                    borderRadius: const BorderRadius.all(Radius.circular(34)),
                    border: Border.fromBorderSide(
                      BorderSide(
                        width: 0.3,
                        color: AppColors.neumorphicBorder.withValues(alpha: 0.27),
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sheetShadow.withValues(alpha: 0.16),
                        offset: const Offset(0, 10),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  // Compact vertical padding with 20px bottom padding.
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Space from top edge, then handle.
                        const SizedBox(height: 16),
                        Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.sheetHandle,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Email button comes up from the bottom after the top space.
                        SlideTransition(
                          position: _slide(0.22, 0.58),
                          child: FadeTransition(
                            opacity: _fade(0.22, 0.58),
                            child: AuthOptionButton(
                              label: StringConstants.loginContinueWithEmail,
                              asset: 'assets/at_symbol.svg',
                              background: Colors.white,
                              foreground: Colors.black,
                              isNeumorphic: true,
                              onTap: widget.onEmail,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Apple follows a bit later.
                        SlideTransition(
                          position: _slide(0.36, 0.72),
                          child: FadeTransition(
                            opacity: _fade(0.36, 0.72),
                            child: AuthOptionButton(
                              label: StringConstants.loginContinueWithApple,
                              asset: 'assets/apple_logo.svg',
                              background: Colors.white,
                              foreground: Colors.black,
                              isNeumorphic: true,
                              onTap: widget.onApple,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Google at the end of the stagger.
                        SlideTransition(
                          position: _slide(0.50, 0.86),
                          child: FadeTransition(
                            opacity: _fade(0.50, 0.86),
                            child: AuthOptionButton(
                              label: StringConstants.loginContinueWithGoogle,
                              asset: 'assets/google_logo.svg',
                              background: AppColors.googleButtonBackground,
                              foreground: Colors.white,
                              useOriginalIconColors: true,
                              onTap: widget.onGoogle,
                            ),
                          ),
                        ),
                        // Gap before terms text matches gap between buttons (16px).
                        const SizedBox(height: 16),
                        // Terms text appears last near the end.
                        SlideTransition(
                          position: _slide(0.64, 1.0),
                          child: FadeTransition(
                            opacity: _fade(0.64, 1.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                style: AppTypography.termsBase,
                                children: [
                                  TextSpan(
                                    text: StringConstants.loginTermsPrefix,
                                  ),
                                  TextSpan(
                                    text: StringConstants.loginTermsEmphasis,
                                    style: AppTypography.termsEmphasis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
