# Error UX Implementation Guide

## Overview

This document explains how errors are displayed to users for an improved user experience in the Flutter Login Google application.

## Error Display Strategy

### 1. **Error Types & Visual Indicators**

Errors are categorized and displayed with appropriate visual cues:

| Error Type | Icon | Color | Retry Available |
|------------|------|-------|-----------------|
| Network | `wifi_off` | Error container | ✅ Yes |
| Authentication | `lock_outline` | Error container | ✅ Yes |
| Server | `error_outline` | Error container | ✅ Yes |
| Unknown | `error_outline` | Error container | ❌ No |

### 2. **Error Banner Component**

**Location**: `lib/core/widgets/error_banner.dart`

A reusable error banner widget that:
- Shows error message with appropriate icon
- Displays retry button for retryable errors
- Allows dismissing errors
- Uses theme-aware colors
- Responsive and accessible

**Features**:
- ✅ Contextual icons based on error type
- ✅ Retry button for recoverable errors
- ✅ Dismiss button to clear errors
- ✅ Theme-aware styling
- ✅ Clear visual hierarchy

### 3. **Error Display Locations**

#### Login Page
- **Position**: Top of the screen (below SafeArea)
- **Behavior**: 
  - Shows inline error banner
  - Retry button triggers sign-in again
  - Dismiss button clears error state
- **User Flow**: User can retry sign-in without leaving the page

#### Home Page
- **Position**: Top of the screen (below AppBar)
- **Behavior**:
  - Shows inline error banner for sign-out errors
  - Retry button retries sign-out
  - Dismiss button clears error state
- **User Flow**: User stays on home (posts) page, can retry or dismiss

#### Posts Page (Home Content)
- **Position**: Top of the screen when initial load fails
- **Behavior**:
  - Shows inline error banner for posts API errors
  - Retry triggers refresh
  - Infinite scroll shows a bottom loader while loading more pages

### 4. **Error State Management**

**AuthError State** includes:
```dart
class AuthError extends AuthState {
  final String message;           // User-friendly message
  final AuthErrorType? errorType; // Error category
  final bool canRetry;            // Whether retry is possible
}
```

**Error Type Mapping**:
- `NetworkFailure` → `AuthErrorType.network` + `canRetry: true`
- `AuthFailure` → `AuthErrorType.authentication` + `canRetry: true`
- `ServerFailure` → `AuthErrorType.server` + `canRetry: true`
- `UnknownFailure` → `AuthErrorType.unknown` + `canRetry: false`

### 5. **User Experience Flow**

#### Sign-In Error Flow:
```
User taps "Sign in with Google"
    ↓
Loading indicator shown
    ↓
Error occurs (e.g., network error)
    ↓
Error banner appears at top
    ├─ Shows error message
    ├─ Shows retry button (if retryable)
    └─ Shows dismiss button
    ↓
User can:
    ├─ Tap "Retry" → Retries sign-in
    └─ Tap "Dismiss" → Clears error, stays on login page
```

#### Sign-Out Error Flow:
```
User taps logout button
    ↓
Error occurs (e.g., network error)
    ↓
Error banner appears at top
    ├─ Shows error message
    ├─ Shows retry button (if retryable)
    └─ Shows dismiss button
    ↓
User can:
    ├─ Tap "Retry" → Retries sign-out
    └─ Tap "Dismiss" → Clears error, stays on home page
```

## Error Messages

All error messages are user-friendly and actionable:

### Network Errors
- **Message**: "Network error. Please check your internet connection."
- **Action**: User can check connection and retry

### Authentication Errors
- **Message**: Specific to error (e.g., "Invalid credentials. Please try again.")
- **Action**: User can retry sign-in

### Server Errors
- **Message**: "Sign in failed. Please try again."
- **Action**: User can retry

### Unknown Errors
- **Message**: "An unknown error occurred."
- **Action**: No retry (user should contact support)

## Best Practices

1. **Never show technical errors** - Always use user-friendly messages
2. **Provide actionable feedback** - Tell users what they can do
3. **Allow retry for recoverable errors** - Network/auth errors can be retried
4. **Don't block UI** - Errors are dismissible, user can continue
5. **Visual consistency** - Use same error banner across app
6. **Accessibility** - Error messages are clear and readable
7. **No magic numbers** - Use `UiConstants` tokens for spacing/radius/sizes (consistent UI)

## Customization

### Adding New Error Types

1. Add error type to `AuthErrorType` enum
2. Add mapping in `_mapFailureToAuthError()` method
3. Add icon/color logic in `ErrorBanner` widget
4. Add error message to `StringConstants`

### Styling Errors

Error banner uses theme colors:
- `colorScheme.error` - Error color
- `colorScheme.errorContainer` - Background color
- `colorScheme.onErrorContainer` - Text color

Customize in `ErrorBanner` widget's `_getBackgroundColor()` method.

## Example Usage

```dart
// Error banner automatically appears when AuthError state is emitted
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthError) {
      return ErrorBanner(
        message: state.message,
        errorType: _mapErrorType(state.errorType),
        canRetry: state.canRetry,
        onRetry: () => context.read<AuthBloc>().add(RetryEvent()),
        onDismiss: () => context.read<AuthBloc>().add(DismissErrorEvent()),
      );
    }
    // ... rest of UI
  },
)
```

## Benefits

✅ **Better UX**: Clear, actionable error messages
✅ **User Control**: Users can retry or dismiss errors
✅ **Visual Feedback**: Icons and colors indicate error type
✅ **Non-blocking**: Errors don't prevent user from continuing
✅ **Consistent**: Same error display pattern across app
✅ **Accessible**: Clear messages and visual indicators
