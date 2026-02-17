import 'package:flutter_bloc/flutter_bloc.dart';

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

  Future<void> _onPostFetchRequested(
    PostFetchRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(const PostLoading());
    try {
      final posts = await _getPosts(page: event.page, limit: event.limit);
      emit(PostLoaded(
        posts: posts,
        currentPage: event.page,
        hasMore: posts.length >= event.limit,
      ));
    } on Failure catch (failure) {
      emit(PostError(ErrorMapper.getErrorMessage(failure)));
    } catch (e) {
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
      return;
    }

    // Show loading state with existing posts
    emit(PostLoading(posts: currentState.posts));

    try {
      final nextPage = currentState.currentPage + 1;
      final newPosts = await _getPosts(page: nextPage, limit: _defaultLimit);

      emit(PostLoaded(
        posts: [...currentState.posts, ...newPosts],
        currentPage: nextPage,
        hasMore: newPosts.length >= _defaultLimit,
      ));
    } on Failure catch (failure) {
      // On error, go back to loaded state with existing posts
      emit(PostLoaded(
        posts: currentState.posts,
        currentPage: currentState.currentPage,
        hasMore: currentState.hasMore,
      ));
      emit(PostError(ErrorMapper.getErrorMessage(failure)));
    } catch (e) {
      final failure = ErrorMapper.mapExceptionToFailure(e);
      emit(PostLoaded(
        posts: currentState.posts,
        currentPage: currentState.currentPage,
        hasMore: currentState.hasMore,
      ));
      emit(PostError(ErrorMapper.getErrorMessage(failure)));
    }
  }

  Future<void> _onPostRefreshRequested(
    PostRefreshRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(const PostLoading());
    try {
      final posts = await _getPosts(page: 1, limit: _defaultLimit);
      emit(PostLoaded(
        posts: posts,
        currentPage: 1,
        hasMore: posts.length >= _defaultLimit,
      ));
    } on Failure catch (failure) {
      emit(PostError(ErrorMapper.getErrorMessage(failure)));
    } catch (e) {
      final failure = ErrorMapper.mapExceptionToFailure(e);
      emit(PostError(ErrorMapper.getErrorMessage(failure)));
    }
  }
}
