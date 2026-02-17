import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_login_google/core/constants/route_constants.dart';
import 'package:flutter_login_google/core/di/service_locator.dart';
import 'package:flutter_login_google/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_login_google/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_login_google/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_login_google/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_login_google/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_login_google/features/home/presentation/pages/home_page.dart';

UserEntity? _firebaseUserToEntity() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  return UserEntity(
    uid: user.uid,
    email: user.email ?? '',
    displayName: user.displayName,
    photoUrl: user.photoURL,
  );
}

class _NavLogger extends NavigatorObserver {
  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[Navigation] $message');
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('PUSH ${route.settings.name ?? route.settings} (from ${previousRoute?.settings.name ?? previousRoute?.settings})');
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('POP ${route.settings.name ?? route.settings} (back to ${previousRoute?.settings.name ?? previousRoute?.settings})');
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _log('REPLACE ${oldRoute?.settings.name ?? oldRoute?.settings} -> ${newRoute?.settings.name ?? newRoute?.settings}');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: RouteConstants.login,
  debugLogDiagnostics: kDebugMode,
  observers: <NavigatorObserver>[
    _NavLogger(),
  ],
  redirect: (context, state) async {
    final persistLogin = await sl<AuthLocalDataSource>().getPersistLogin();
    final firebaseLoggedIn = FirebaseAuth.instance.currentUser != null;

    // Treat user as "allowed to be logged in" only if persistLogin=true AND Firebase has a user.
    final allowHome = persistLogin && firebaseLoggedIn;

    final location = state.uri.path;
    final onLogin = location == RouteConstants.login;
    final onHome = location == RouteConstants.home;

    if (!allowHome && onHome) {
      if (kDebugMode) {
        debugPrint('[Router] redirect ${state.uri} -> ${RouteConstants.login} (persistLogin=$persistLogin, firebaseLoggedIn=$firebaseLoggedIn)');
      }
      return RouteConstants.login;
    }
    if (allowHome && onLogin) {
      if (kDebugMode) {
        debugPrint('[Router] redirect ${state.uri} -> ${RouteConstants.home} (persistLogin=$persistLogin, firebaseLoggedIn=$firebaseLoggedIn)');
      }
      return RouteConstants.home;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: RouteConstants.login,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>()..add(AuthSetUser(_firebaseUserToEntity())),
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: RouteConstants.home,
      builder: (context, state) {
        final user = (state.extra as UserEntity?) ?? _firebaseUserToEntity();
        return BlocProvider(
          create: (_) => sl<AuthBloc>()..add(AuthSetUser(user)),
          child: const HomePage(),
        );
      },
    ),
  ],
);
