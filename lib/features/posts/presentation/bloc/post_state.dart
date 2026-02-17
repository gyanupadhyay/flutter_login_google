import 'package:equatable/equatable.dart';

import '../../domain/entities/post_entity.dart';

sealed class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

final class PostInitial extends PostState {
  const PostInitial();
}

final class PostLoading extends PostState {
  const PostLoading({this.posts = const []});

  final List<PostEntity> posts;

  @override
  List<Object?> get props => [posts];
}

final class PostLoaded extends PostState {
  const PostLoaded({
    required this.posts,
    this.currentPage = 1,
    this.hasMore = true,
  });

  final List<PostEntity> posts;
  final int currentPage;
  final bool hasMore;

  @override
  List<Object?> get props => [posts, currentPage, hasMore];
}

/// Used when fetching the next page; keeps list visible and shows bottom loader.
final class PostPaginating extends PostLoaded {
  const PostPaginating({
    required super.posts,
    required super.currentPage,
    required super.hasMore,
  });
}

final class PostError extends PostState {
  const PostError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
