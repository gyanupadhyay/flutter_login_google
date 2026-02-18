import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Shared text styles used across the app.
class AppTypography {
  AppTypography._();

  /// Big hero title on the login screen.
  static const TextStyle loginHeroTitle = TextStyle(
    fontFamily: '.SF Pro Rounded',
    fontFamilyFallback: [
      'SF Pro Rounded',
      'SF Pro Display',
      'SF Pro Text',
    ],
    fontSize: 48,
    fontWeight: FontWeight.w500,
    height: 0.85,
    letterSpacing: -0.96,
    color: Colors.black,
  );

  /// Subtitle under the hero title on the login screen.
  static const TextStyle loginHeroSubtitle = TextStyle(
    fontFamily: '.SF Pro Rounded',
    fontFamilyFallback: [
      'SF Pro Rounded',
      'SF Pro Display',
      'SF Pro Text',
    ],
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0,
    color: AppColors.loginSubtitle,
  );

  /// Label for the primary call-to-action buttons.
  static const TextStyle primaryCta = TextStyle(
    fontFamily: '.SF Pro Rounded',
    fontFamilyFallback: [
      'SF Pro Rounded',
      'SF Pro Display',
      'SF Pro Text',
    ],
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0,
    color: Colors.black,
  );

  /// Label for auth option buttons inside the sheet.
  static const TextStyle authOptionLabel = TextStyle(
    fontFamily: '.SF Pro Rounded',
    fontFamilyFallback: [
      'SF Pro Rounded',
      'SF Pro Display',
      'SF Pro Text',
    ],
    fontSize: 15.83,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0,
    color: Colors.black,
  );

  /// Base style for "By continuing, you agree to our …".
  static const TextStyle termsBase = TextStyle(
    fontFamily: '.SF Pro Rounded',
    fontFamilyFallback: [
      'SF Pro Rounded',
      'SF Pro Display',
      'SF Pro Text',
    ],
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.0,
    letterSpacing: 0,
    color: Colors.black54,
  );

  /// Emphasis style for the "Terms" word.
  static const TextStyle termsEmphasis = TextStyle(
    fontFamily: '.SF Pro Rounded',
    fontFamilyFallback: [
      'SF Pro Rounded',
      'SF Pro Display',
      'SF Pro Text',
    ],
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0,
    color: Colors.black54,
  );
}

