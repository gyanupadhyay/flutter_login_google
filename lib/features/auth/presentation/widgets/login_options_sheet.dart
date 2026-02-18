import 'package:flutter/material.dart';

import 'package:flutter_login_google/core/constants/app_colors.dart';
import 'package:flutter_login_google/core/constants/app_typography.dart';
import 'package:flutter_login_google/core/constants/ui_constants.dart';
import 'package:flutter_login_google/core/constants/asset_constants.dart';
import 'package:flutter_login_google/core/constants/string_constants.dart';
import 'package:flutter_login_google/features/auth/presentation/widgets/auth_option_button.dart';

class LoginOptionsSheet extends StatefulWidget {
  const LoginOptionsSheet({
    super.key,
    required this.onEmail,
    required this.onApple,
    required this.onGoogle,
  });

  final VoidCallback onEmail;
  final VoidCallback onApple;
  final VoidCallback onGoogle;

  @override
  State<LoginOptionsSheet> createState() => _LoginOptionsSheetState();
}

class _LoginOptionsSheetState extends State<LoginOptionsSheet>
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

  Animation<Offset> _slide(double begin, double end) => Tween<Offset>(
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
                    borderRadius:
                        const BorderRadius.all(Radius.circular(AppRadii.xxl)),
                    border: Border.fromBorderSide(
                      BorderSide(
                        width: 0.3,
                        color: AppColors.neumorphicBorder.withValues(
                          alpha: 0.27,
                        ),
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    boxShadow: const [
                      // Soft top highlight to mimic extruded surface.
                      BoxShadow(
                        color: AppColors.neumorphicHighlight,
                        offset: Offset(0, -3),
                        blurRadius: 4,
                      ),
                      // Soft bottom shade.
                      BoxShadow(
                        color: AppColors.neumorphicShade,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                      // Main drop shadow for depth.
                      BoxShadow(
                        color: AppColors.neumorphicShadow,
                        offset: Offset(0, 10),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        SlideTransition(
                          position: _slide(0.22, 0.58),
                          child: FadeTransition(
                            opacity: _fade(0.22, 0.58),
                            child: AuthOptionButton(
                              label: StringConstants.loginContinueWithEmail,
                              asset: AssetConstants.atSymbolSvg,
                              background: Colors.white,
                              foreground: Colors.black,
                              isNeumorphic: true,
                              onTap: widget.onEmail,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SlideTransition(
                          position: _slide(0.36, 0.72),
                          child: FadeTransition(
                            opacity: _fade(0.36, 0.72),
                            child: AuthOptionButton(
                              label: StringConstants.loginContinueWithApple,
                              asset: AssetConstants.appleLogoSvg,
                              background: Colors.white,
                              foreground: Colors.black,
                              isNeumorphic: true,
                              onTap: widget.onApple,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SlideTransition(
                          position: _slide(0.50, 0.86),
                          child: FadeTransition(
                            opacity: _fade(0.50, 0.86),
                            child: AuthOptionButton(
                              label: StringConstants.loginContinueWithGoogle,
                              asset: AssetConstants.googleLogoSvg,
                              background: AppColors.googleButtonBackground,
                              foreground: Colors.white,
                              useOriginalIconColors: true,
                              onTap: widget.onGoogle,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
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

