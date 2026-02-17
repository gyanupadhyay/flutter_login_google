import 'package:flutter/material.dart';

import '../constants/string_constants.dart';
import '../constants/ui_constants.dart';

/// A reusable error banner widget for displaying errors with different styles.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    this.errorType,
    this.canRetry = false,
    this.onRetry,
    this.onDismiss,
  });

  final String message;
  final ErrorType? errorType;
  final bool canRetry;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconData = _getIconForErrorType(errorType);
    final backgroundColor = _getBackgroundColor(errorType, colorScheme);

    return Container(
      margin: AppInsets.bannerMargin,
      padding: AppInsets.bannerPadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            color: colorScheme.error,
            size: AppSizes.iconLg,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontSize: AppSizes.errorText,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: AppSizes.iconSm),
              color: colorScheme.onErrorContainer,
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (canRetry && onRetry != null) ...[
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                minimumSize: const Size(0, AppSizes.bannerMinButtonHeight),
              ),
              child: const Text(StringConstants.retry),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIconForErrorType(ErrorType? type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.authentication:
        return Icons.lock_outline;
      case ErrorType.server:
        return Icons.error_outline;
      case ErrorType.unknown:
      default:
        return Icons.error_outline;
    }
  }

  Color _getBackgroundColor(ErrorType? type, ColorScheme colorScheme) {
    switch (type) {
      case ErrorType.network:
        return colorScheme.errorContainer.withValues(alpha: 0.3);
      case ErrorType.authentication:
        return colorScheme.errorContainer.withValues(alpha: 0.3);
      case ErrorType.server:
        return colorScheme.errorContainer.withValues(alpha: 0.3);
      case ErrorType.unknown:
      default:
        return colorScheme.errorContainer.withValues(alpha: 0.2);
    }
  }
}

/// Error type enum for UI display purposes.
enum ErrorType {
  network,
  authentication,
  server,
  unknown,
}
