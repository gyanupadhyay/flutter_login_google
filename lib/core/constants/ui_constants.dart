import 'package:flutter/widgets.dart';

/// UI design tokens (spacing, radii, sizes) to avoid magic numbers in widgets.
///
/// Colors should generally come from `Theme.of(context)` / `ColorScheme`.
class UiConstants {
  UiConstants._();
}

/// Spacing scale (in logical pixels).
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Border radius scale (in logical pixels).
class AppRadii {
  AppRadii._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
}

/// Common paddings/margins (built from the spacing scale).
class AppInsets {
  AppInsets._();

  /// Typical page/list padding.
  static const EdgeInsets screen = EdgeInsets.all(AppSpacing.lg);

  /// Typical card content padding.
  static const EdgeInsets card = EdgeInsets.all(AppSpacing.lg);

  /// Banner padding and margin.
  static const EdgeInsets bannerPadding = EdgeInsets.all(AppSpacing.lg);
  static const EdgeInsets bannerMargin = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.sm,
  );

  /// Login page content padding.
  static const EdgeInsets loginContent = EdgeInsets.symmetric(
    horizontal: AppSpacing.xl,
  );

  /// Small badge/chip padding.
  static const EdgeInsets badge = EdgeInsets.symmetric(
    horizontal: AppSpacing.sm,
    vertical: AppSpacing.xs,
  );

  /// Button padding.
  static const EdgeInsets primaryButton = EdgeInsets.symmetric(
    horizontal: AppSpacing.xl,
    vertical: AppSpacing.lg,
  );
}

/// Common component sizes.
class AppSizes {
  AppSizes._();

  static const double iconLg = 24;
  static const double iconSm = 20;

  static const double bannerMinButtonHeight = 32;

  static const double postBadgeText = 12;
  static const double errorText = 14;

  /// When within this many pixels from bottom, trigger pagination.
  static const double scrollLoadMoreThreshold = 200;

  /// Height for bottom pagination indicator.
  static const double paginationIndicatorHeight = 4;
}

