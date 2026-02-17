/// Application string constants for UI text.
class StringConstants {
  StringConstants._();

  // Login Page
  static const String welcome = 'Welcome';
  static const String signInWithGoogleToContinue =
      'Sign in with Google to continue';
  static const String signInWithGoogle = 'Sign in with Google';

  // Home Page
  static const String home = 'Home';
  static const String user = 'User';

  // Error Messages
  static const String signInFailed = 'Sign in failed. Please try again.';
  static const String signOutFailed = 'Sign out failed. Please try again.';
  static const String unknownError = 'An unknown error occurred.';
  static const String networkError =
      'Network error. Please check your internet connection.';
  static const String signInCancelled = 'Sign in was cancelled.';
  static const String userDisabled =
      'This account has been disabled. Please contact support.';
  static const String invalidCredentials =
      'Invalid credentials. Please try again.';
  static const String tooManyRequests =
      'Too many requests. Please try again later.';
  static const String operationNotAllowed =
      'This operation is not allowed. Please contact support.';
  static const String accountExistsWithDifferentCredential =
      'An account already exists with a different sign-in method.';
  static const String signInRequired = 'Please sign in to continue.';
  static const String retry = 'Retry';
  static const String dismiss = 'Dismiss';
}
