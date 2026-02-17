import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_login_google/core/error/error_mapper.dart';
import 'package:flutter_login_google/core/error/failure.dart';
import 'package:flutter_login_google/features/posts/domain/usecases/get_posts.dart';
import 'package:flutter_login_google/features/posts/presentation/bloc/post_event.dart';
import 'package:flutter_login_google/features/posts/presentation/bloc/post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required GetPosts getPosts})
      : _getPosts = getPosts,
        super(const PostInitial()) {
    on<PostFetchRequested>(_onPostFetchRequested);
    on<PostLoadMoreRequested>(_onPostLoadMoreRequested);
    on<PostRefreshRequested>(_onPostRefreshRequested);
  }

  final GetPosts _getPosts;
  static const int _defaultLimit = 10;
  bool _isPaginating = false;

  Future<void> _onPostFetchRequested(
    PostFetchRequested event,
    Emitter<PostState> emit,
  ) async {
    if (kDebugMode) {
      debugPrint('[PostBloc] fetch requested page=${event.page} limit=${event.limit}');
    }
    emit(const PostLoading());
    try {
      final posts = await _getPosts(page: event.page, limit: event.limit);
      if (kDebugMode) {
        debugPrint('[PostBloc] fetch success page=${event.page} received=${posts.length}');
      }
      emit(PostLoaded(
        posts: posts,
        currentPage: event.page,
        hasMore: posts.length >= event.limit,
      ));
    } on Failure catch (failure) {
      if (kDebugMode) {
        debugPrint('[PostBloc] fetch failure: ${failure.runtimeType}: ${failure.message}');
      }
      emit(PostError(ErrorMapper.getErrorMessage(failure)));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PostBloc] fetch threw: $e');
      }
      final failure = ErrorMapper.mapExceptionToFailure(e);
      emit(PostError(ErrorMapper.getErrorMessage(failure)));
    }
  }

  Future<void> _onPostLoadMoreRequested(
    PostLoadMoreRequested event,
    Emitter<PostState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PostLoaded || !currentState.hasMore) {
      if (kDebugMode) {
        debugPrint('[PostBloc] loadMore ignored: state=${currentState.runtimeType} hasMore=${currentState is PostLoaded ? currentState.hasMore : 'n/a'}');
      }
      return;
    }
    if (currentState is PostPaginating) return;
    if (_isPaginating) return;
    _isPaginating = true;

    if (kDebugMode) {
      debugPrint('[PostBloc] loadMore start currentPage=${currentState.currentPage} currentCount=${currentState.posts.length}');
    }

    // Keep list visible and show bottom loader (like reference implementation).
    emit(PostPaginating(
      posts: currentState.posts,
      currentPage: currentState.currentPage,
      hasMore: currentState.hasMore,
    ));

    try {
      // Artificial delay so the pagination indicator is clearly visible.
      await Future<void>.delayed(const Duration(milliseconds: 400));

      final nextPage = currentState.currentPage + 1;
      if (kDebugMode) {
        debugPrint('[PostBloc] requesting nextPage=$nextPage limit=$_defaultLimit');
      }
      final newPosts = await _getPosts(page: nextPage, limit: _defaultLimit);
      if (kDebugMode) {
        debugPrint('[PostBloc] loadMore success nextPage=$nextPage received=${newPosts.length}');
      }

      if (newPosts.isEmpty) {
        emit(PostLoaded(
          posts: currentState.posts,
          currentPage: currentState.currentPage,
          hasMore: false,
        ));
        return;
      }

      emit(PostLoaded(
        posts: [...currentState.posts, ...newPosts],
        currentPage: nextPage,
        hasMore: newPosts.length >= _defaultLimit,
      ));
    } on Failure catch (failure) {
      if (kDebugMode) {
        debugPrint('[PostBloc] loadMore failure: ${failure.runtimeType}: ${failure.message}');
      }
      // On error, go back to loaded state with existing posts
      emit(PostLoaded(
        posts: currentState.posts,
        currentPage: currentState.currentPage,
        hasMore: currentState.hasMore,
      ));
      emit(PostError(ErrorMapper.getErrorMessage(failure)));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PostBloc] loadMore threw: $e');
      }
      final failure = ErrorMapper.mapExceptionToFailure(e);
      emit(PostLoaded(
        posts: currentState.posts,
        currentPage: currentState.currentPage,
        hasMore: currentState.hasMore,
      ));
      emit(PostError(ErrorMapper.getErrorMessage(failure)));
    } finally {
      _isPaginating = false;
    }
  }

  Future<void> _onPostRefreshRequested(
    PostRefreshRequested event,
    Emitter<PostState> emit,
  ) async {
    if (kDebugMode) {
      debugPrint('[PostBloc] refresh requested');
    }
    emit(const PostLoading());
    try {
      final posts = await _getPosts(page: 1, limit: _defaultLimit);
      if (kDebugMode) {
        debugPrint('[PostBloc] refresh success received=${posts.length}');
      }
      emit(PostLoaded(
        posts: posts,
        currentPage: 1,
        hasMore: posts.length >= _defaultLimit,
      ));
    } on Failure catch (failure) {
      if (kDebugMode) {
        debugPrint('[PostBloc] refresh failure: ${failure.runtimeType}: ${failure.message}');
      }
      emit(PostError(ErrorMapper.getErrorMessage(failure)));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PostBloc] refresh threw: $e');
      }
      final failure = ErrorMapper.mapExceptionToFailure(e);
      emit(PostError(ErrorMapper.getErrorMessage(failure)));
    }
  }
}
