import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class GetPosts {
  GetPosts(this._repository);

  final PostRepository _repository;

  Future<List<PostEntity>> call({
    required int page,
    required int limit,
  }) =>
      _repository.getPosts(page: page, limit: limit);
}
