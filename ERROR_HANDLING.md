# Error Handling Architecture

## Overview

This document explains how API errors are handled and displayed to users in the Flutter Login Google application.

## Error Handling Flow

```
API/Service Error
    ↓
Data Source Layer (catches exceptions, re-throws)
    ↓
Repository Layer (maps exceptions to Failure objects)
    ↓
Use Case Layer (passes through)
    ↓
BLoC Layer (catches Failure, emits AuthError state)
    ↓
UI Layer (displays error message to user)
```

## Components

### 1. Failure Classes (`lib/core/error/failure.dart`)

Base failure classes representing different error types:
- `Failure` - Base class for all failures
- `ServerFailure` - Server/API errors
- `NetworkFailure` - Network connectivity issues
- `AuthFailure` - Authentication errors
- `CancellationFailure` - User cancellation
- `UnknownFailure` - Unknown/unexpected errors

### 2. Error Mapper (`lib/core/error/error_mapper.dart`)

Maps technical exceptions to user-friendly error messages:

**Firebase Auth Exceptions:**
- `network-request-failed` → Network error message
- `user-disabled` → User disabled message
- `invalid-credential` → Invalid credentials message
- `too-many-requests` → Too many requests message
- And more...

**Google Sign-In Exceptions:**
- `canceled` → Sign in cancelled (silently handled)
- `interrupted` → May map to network/auth failure depending on description
- `clientConfigurationError` / `providerConfigurationError` → Configuration/auth failure
- Other codes → Mapped based on `description` (e.g. network keywords)

**HTTP / REST Exceptions:**
- `http.ClientException` → Network error message
- Non-200 responses → `ServerFailure(...)` (server/API failure)

### 3. String Constants (`lib/core/constants/string_constants.dart`)

User-friendly error messages:
- `networkError` - "Network error. Please check your internet connection."
- `signInFailed` - "Sign in failed. Please try again."
- `signInCancelled` - "Sign in was cancelled."
- `userDisabled` - "This account has been disabled. Please contact support."
- And more...

## Error Flow Example: Sign In

### Step 1: Data Source
```dart
// lib/features/auth/data/datasources/auth_remote_datasource.dart
try {
  // API call
} on FirebaseAuthException {
  rethrow; // Let repository handle
} on GoogleSignInException {
  rethrow; // Let repository handle
}
```

### Step 2: Repository
```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
try {
  return await _remoteDataSource.signInWithGoogle();
} on FirebaseAuthException catch (e) {
  throw ErrorMapper.mapExceptionToFailure(e);
} on GoogleSignInException catch (e) {
  if (e.code == GoogleSignInExceptionCode.canceled) {
    return null; // Silent cancellation
  }
  throw ErrorMapper.mapExceptionToFailure(e);
}
```

### Step 3: BLoC
```dart
// lib/features/auth/presentation/bloc/auth_bloc.dart
try {
  final user = await _signInWithGoogle();
  if (user != null) {
    emit(AuthAuthenticated(user));
  } else {
    emit(const AuthUnauthenticated()); // Cancellation
  }
} on Failure catch (failure) {
  if (failure is CancellationFailure) {
    emit(const AuthUnauthenticated()); // Silent cancellation
  } else {
    emit(AuthError(ErrorMapper.getErrorMessage(failure)));
  }
}
```

### Step 4: UI
```dart
// lib/features/auth/presentation/pages/login_page.dart
// When AuthError is emitted, an inline ErrorBanner is shown at the top
// with retry + dismiss actions (no SnackBar).
```

## Error Types & User Experience

### 1. Network Errors
- **Detection**: Network-related exceptions or Firebase `network-request-failed`
- **User Message**: "Network error. Please check your internet connection."
- **Action**: User can retry

### 2. Authentication Errors
- **Detection**: Invalid credentials, disabled account, etc.
- **User Message**: Specific message based on error code
- **Action**: User can retry or contact support

### 3. User Cancellation
- **Detection**: Google Sign-In `canceled` exception
- **User Message**: None (silent handling)
- **Action**: User stays on login page

### 4. Unknown Errors
- **Detection**: Any unhandled exception
- **User Message**: "An unknown error occurred."
- **Action**: User can retry

## Best Practices

1. **Never show technical errors to users** - Always map to user-friendly messages
2. **Handle cancellations silently** - Don't show error when user cancels
3. **Provide actionable messages** - Tell users what they can do
4. **Log technical details** - AuthBloc prints sign-in errors in debug mode for troubleshooting
5. **Consistent error handling** - Use the same pattern across all features

## Adding New Error Types

1. Add error message to `StringConstants`
2. Add mapping logic to `ErrorMapper`
3. Update BLoC to handle new error type
4. Update UI if needed for special error handling

## Example: Adding a New Error

```dart
// 1. Add to StringConstants
static const String accountLocked = 'Your account has been locked.';

// 2. Add mapping in ErrorMapper
case 'account-locked':
  return AuthFailure(StringConstants.accountLocked);

// 3. BLoC automatically handles it (no changes needed)
// 4. UI automatically displays it (no changes needed)
```
