import 'package:flutter/material.dart';

/// Central place for shared color tokens that aren't coming directly
/// from [ColorScheme].
class AppColors {
  AppColors._();

  /// Login screen background.
  static const Color loginBackground = Color(0xFFF5F5F5);

  /// Bottom sheet surface.
  static const Color sheetBackground = Color(0xFFFFFFFF);

  /// Small drag handle line color.
  static const Color sheetHandle = Color(0xFFD9D9D9);

  /// Subtitle/body color under the hero title.
  static const Color loginSubtitle = Color(0xFF9C9C9C);

  /// Dark Google button background.
  static const Color googleButtonBackground = Color(0xFF2B2B2B);

  /// Neumorphic button surface (#F2F2F2 @ 20%).
  static const Color neumorphicSurface = Color(0x33F2F2F2);

  /// Neumorphic border.
  static const Color neumorphicBorder = Color(0xFFFFFFFF);

  /// Neumorphic inner highlight.
  static const Color neumorphicHighlight = Color(0x33F9F9F9);

  /// Neumorphic inner shade.
  static const Color neumorphicShade = Color(0x40F3F3F3);

  /// Neumorphic drop shadow.
  static const Color neumorphicShadow = Color(0x0D000000);

  /// Main sheet drop shadow base color.
  static const Color sheetShadow = Color(0xFF757575);
}

