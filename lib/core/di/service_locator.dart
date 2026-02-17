import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter_login_google/core/storage/secure_storage_service.dart';
import 'package:flutter_login_google/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_login_google/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_login_google/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_login_google/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_login_google/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:flutter_login_google/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter_login_google/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_login_google/features/posts/data/datasources/post_remote_datasource.dart';
import 'package:flutter_login_google/features/posts/data/repositories/post_repository_impl.dart';
import 'package:flutter_login_google/features/posts/domain/repositories/post_repository.dart';
import 'package:flutter_login_google/features/posts/domain/usecases/get_posts.dart';
import 'package:flutter_login_google/features/posts/presentation/bloc/post_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Initialize GoogleSignIn
  await GoogleSignIn.instance.initialize();

  // Secure storage
  sl.registerLazySingleton(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton(() => SecureStorageService(sl()));
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storage: sl()),
  );

  // Auth Bloc
  sl.registerFactory(
    () => AuthBloc(signInWithGoogle: sl(), signOut: sl()),
  );

  // Posts Bloc
  sl.registerFactory(
    () => PostBloc(getPosts: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetPosts(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(),
  );
}
