import 'package:equatable/equatable.dart';

sealed class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

final class PostFetchRequested extends PostEvent {
  const PostFetchRequested({this.page = 1, this.limit = 10});

  final int page;
  final int limit;

  @override
  List<Object?> get props => [page, limit];
}

final class PostLoadMoreRequested extends PostEvent {
  const PostLoadMoreRequested();
}

final class PostRefreshRequested extends PostEvent {
  const PostRefreshRequested();
}
