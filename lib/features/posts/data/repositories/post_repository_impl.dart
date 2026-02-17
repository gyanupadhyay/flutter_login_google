import 'package:flutter_login_google/core/error/error_mapper.dart';
import 'package:flutter_login_google/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_login_google/features/posts/domain/repositories/post_repository.dart';
import 'package:flutter_login_google/features/posts/data/datasources/post_remote_datasource.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({required PostRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final PostRemoteDataSource _remoteDataSource;

  @override
  Future<List<PostEntity>> getPosts({
    required int page,
    required int limit,
  }) async {
    try {
      return await _remoteDataSource.getPosts(page: page, limit: limit);
    } catch (e) {
      throw ErrorMapper.mapExceptionToFailure(e);
    }
  }
}
