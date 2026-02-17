import '../entities/post_entity.dart';

/// Abstract post repository contract.
abstract class PostRepository {
  Future<List<PostEntity>> getPosts({required int page, required int limit});
}
