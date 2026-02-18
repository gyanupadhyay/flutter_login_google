import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_login_google/core/constants/app_colors.dart';
import 'package:flutter_login_google/core/constants/app_typography.dart';

class AuthOptionButton extends StatelessWidget {
  const AuthOptionButton({
    super.key,
    required this.label,
    required this.asset,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.useOriginalIconColors = false,
    this.isNeumorphic = false,
  });

  final String label;
  final String asset;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  /// If true, the SVG icon keeps its original colors.
  final bool useOriginalIconColors;
  final bool isNeumorphic;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(32);

    final BoxDecoration decoration;
    if (isNeumorphic) {
      decoration = BoxDecoration(
        color: AppColors.neumorphicSurface,
        borderRadius: radius,
        border: Border.all(
          color: AppColors.neumorphicBorder,
          width: 2,
        ),
        boxShadow: const [
          // Approximate inner highlight
          BoxShadow(
            color: AppColors.neumorphicHighlight,
            offset: Offset(0, -3),
            blurRadius: 4,
          ),
          // Approximate inner shade
          BoxShadow(
            color: AppColors.neumorphicShade,
            offset: Offset(0, 2),
            blurRadius: 4.2,
          ),
          // Drop shadow
          BoxShadow(
            color: AppColors.neumorphicShadow,
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      );
    } else {
      decoration = BoxDecoration(
        color: background,
        borderRadius: radius,
      );
    }

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  asset,
                  width: 18,
                  height: 18,
                  colorFilter: useOriginalIconColors
                      ? null
                      : ColorFilter.mode(foreground, BlendMode.srcIn),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AppTypography.authOptionLabel.copyWith(
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

