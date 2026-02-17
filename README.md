# Flutter Google Login App

A Flutter application implementing Google Sign-In authentication using Clean Architecture principles.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Flow Explanation](#flow-explanation)
- [Dependencies](#dependencies)
- [Setup Instructions](#setup-instructions)
- [Running the App](#running-the-app)

## 🎯 Overview

This Flutter app demonstrates Google Sign-In authentication integrated with Firebase Authentication, built using Clean Architecture principles. After login, users see a paginated posts list fetched from JSONPlaceholder.

## 🏗️ Architecture

The application follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI Components, BLoC, Pages)           │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│          Domain Layer                    │
│  (Entities, Use Cases, Repository)       │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│           Data Layer                    │
│  (Models, DataSources, Repository Impl) │
└─────────────────────────────────────────┘
```

### Architecture Layers

1. **Presentation Layer**: Contains UI components, BLoC for state management, and pages
2. **Domain Layer**: Contains business logic, entities, use cases, and repository interfaces
3. **Data Layer**: Contains data models, remote data sources, and repository implementations

## 📁 Project Structure

```
lib/
│
├── app/
│   └── router.dart                    # GoRouter configuration
│
├── core/
│   ├── di/
│   │   └── service_locator.dart       # Dependency injection setup (GetIt)
│   ├── constants/
│   │   ├── api_constants.dart         # Base URLs + endpoints
│   │   ├── app_constants.dart         # Application-wide constants
│   │   ├── route_constants.dart       # Route paths
│   │   ├── string_constants.dart      # UI strings (no hardcoded text)
│   │   └── ui_constants.dart          # UI tokens (spacing/radius/sizes)
│   ├── error/
│   │   ├── error_mapper.dart          # Maps exceptions -> Failures
│   │   └── failure.dart               # Failure types
│   ├── storage/
│   │   ├── secure_storage_keys.dart   # Keys for secure storage
│   │   └── secure_storage_service.dart# Wrapper around FlutterSecureStorage
│   └── widgets/
│       └── error_banner.dart          # Reusable inline error UI
│
├── features/
│   │
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_datasource.dart     # Secure storage (persist_login)
│   │   │   │   └── auth_remote_datasource.dart    # Google Sign-In & Firebase Auth
│   │   │   ├── models/
│   │   │   │   └── user_model.dart                # Data model extending UserEntity
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart      # Repository implementation
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart               # Business entity
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart           # Repository interface
│   │   │   └── usecases/
│   │   │       ├── sign_in_with_google.dart       # Sign in use case
│   │   │       └── sign_out.dart                  # Sign out use case
│   │   │
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart                 # BLoC for auth state management
│   │       │   ├── auth_event.dart                # Auth events
│   │       │   └── auth_state.dart                # Auth states
│   │       └── pages/
│   │           └── login_page.dart                # Login screen UI
│   │
│   ├── posts/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── post_remote_datasource.dart    # JSONPlaceholder API calls
│   │   │   ├── models/
│   │   │   │   └── post_model.dart                # Post model extending PostEntity
│   │   │   └── repositories/
│   │   │       └── post_repository_impl.dart      # Repository implementation
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── post_entity.dart               # Business entity
│   │   │   ├── repositories/
│   │   │   │   └── post_repository.dart           # Repository interface
│   │   │   └── usecases/
│   │   │       └── get_posts.dart                 # Fetch paginated posts
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── post_bloc.dart                 # BLoC for pagination + states
│   │       │   ├── post_event.dart
│   │       │   └── post_state.dart
│   │       └── pages/
│   │           └── post_page.dart                 # Paginated posts UI
│   │
│   └── home/
│       └── presentation/
│           └── pages/
│               └── home_page.dart                 # Hosts PostPage after login
│
└── main.dart                                    # App entry point
```

## 🔄 Flow Explanation

### 1. App Initialization

```
main() 
  → Firebase.initializeApp()
  → initServiceLocator() (Sets up GetIt DI)
  → MyApp (MaterialApp.router with appRouter)
```

### 2. Startup Routing (persisted login)

- The router checks:
  - `persist_login` from secure storage
  - `FirebaseAuth.instance.currentUser`
- If **both** are true, user is redirected to `/home`; otherwise `/login`.

### 2. Login Flow

```
User taps "Sign in with Google"
  ↓
LoginPage dispatches AuthSignInWithGoogleRequested event
  ↓
AuthBloc receives event → emits AuthLoading
  ↓
AuthBloc calls SignInWithGoogle use case
  ↓
Use Case → AuthRepository → AuthRemoteDataSource
  ↓
DataSource: GoogleSignIn.authenticate() → Firebase Auth
  ↓
On success: UserModel created → returned up the chain
  ↓
Repository sets secure flag: persist_login = true
  ↓
AuthBloc emits AuthAuthenticated(user)
  ↓
LoginPage listener detects AuthAuthenticated
  ↓
Navigates to /home: context.go('/home', extra: state.user)
```

### 3. Home (Posts) Flow

```
HomePage receives AuthAuthenticated
  ↓
HomePage shows PostPage (posts list)
  ↓
PostPage dispatches initial PostFetchRequested(page=1, limit=10)
  ↓
PostBloc → GetPosts → PostRepository → PostRemoteDataSource
  ↓
Remote fetch: `GET /posts?_page=1&_limit=10`
  ↓
UI shows list + infinite scroll pagination + pull-to-refresh
  ↓
AppBar shows: "Welcome, <user name>" and logout button
```

### 4. Sign Out Flow

```
User taps logout button
  ↓
HomePage dispatches AuthSignOutRequested event
  ↓
AuthBloc calls SignOut use case
  ↓
Use Case → AuthRepository → AuthRemoteDataSource
  ↓
DataSource: FirebaseAuth.signOut() + GoogleSignIn.signOut()
  ↓
Repository clears secure flag: persist_login removed
  ↓
AuthBloc emits AuthUnauthenticated
  ↓
HomePage navigates to /login: context.go('/login')
```

## 📦 Dependencies

### Core Dependencies

- `flutter_bloc: ^9.1.1` - State management using BLoC pattern
- `get_it: ^9.2.0` - Dependency injection
- `go_router: ^17.1.0` - Declarative routing
- `equatable: ^2.0.8` - Value equality for state/events
- `firebase_core: ^4.4.0` - Firebase core SDK
- `firebase_auth: ^6.1.4` - Firebase Authentication
- `google_sign_in: ^7.2.0` - Google Sign-In plugin
- `http: ^1.6.0` - REST API calls (posts feature)
- `flutter_secure_storage: ^10.0.0` - Persist `persist_login` flag

### Dev Dependencies

- `flutter_lints: ^6.0.0` - Linting rules

## 🚀 Setup Instructions

### Prerequisites

- Flutter SDK (3.12.0 or higher)
- Firebase project configured
- Google Sign-In configured for your platform

### Firebase Setup

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or use an existing one

2. **Android Setup**
   - Add your Android app to Firebase
   - Download `google-services.json`
   - Place it in `android/app/`
   - Add SHA-1 fingerprint to Firebase Console

3. **iOS Setup**
   - Add your iOS app to Firebase
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/`
   - Configure URL schemes in `Info.plist`

4. **Enable Google Sign-In**
   - In Firebase Console → Authentication → Sign-in method
   - Enable Google Sign-In provider

5. **Generate Firebase Options**
   ```bash
   flutterfire configure
   ```

### Google Sign-In Configuration

1. **Android**: Ensure `google-services.json` is properly configured
2. **iOS**: Add your reversed client ID to URL schemes in `Info.plist`

## ▶️ Running the App

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

3. **Run on Specific Device**
   ```bash
   flutter run -d <device-id>
   ```

## 🎨 Features

- ✅ Google Sign-In authentication
- ✅ Firebase Authentication integration
- ✅ Clean Architecture implementation
- ✅ BLoC state management
- ✅ Dependency injection with GetIt
- ✅ Declarative routing with GoRouter
- ✅ Paginated posts list (JSONPlaceholder)
- ✅ Error handling with inline `ErrorBanner`
- ✅ Loading states
- ✅ Persisted-login routing (secure storage flag + Firebase session)
- ✅ Debug navigation logging (router diagnostics)

## 📝 Key Components

### Service Locator (`core/di/service_locator.dart`)

Manages dependency injection using GetIt:
- Registers BLoC instances
- Registers use cases
- Registers repositories
- Registers data sources

### Router (`app/router.dart`)

Manages app navigation:
- `/login` - Login screen
- `/home` - Home screen (requires authentication)

### Auth BLoC (`features/auth/presentation/bloc/auth_bloc.dart`)

Manages authentication state:
- Handles sign-in events
- Handles sign-out events
- Manages authentication state changes

## 🔐 Security Notes

- Never commit Firebase configuration files to public repositories
- Keep your `google-services.json` and `GoogleService-Info.plist` secure
- Use environment variables for sensitive configuration in production

## 📚 Architecture Benefits

1. **Separation of Concerns**: Each layer has a single responsibility
2. **Testability**: Easy to unit test each layer independently
3. **Maintainability**: Changes in one layer don't affect others
4. **Scalability**: Easy to add new features following the same pattern
5. **Reusability**: Domain layer can be reused across different platforms

## 🤝 Contributing

This is a sample project demonstrating Clean Architecture in Flutter. Feel free to use it as a reference for your own projects.

## 📄 License

This project is provided as-is for educational purposes.
