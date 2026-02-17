import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter_login_google/core/constants/api_constants.dart';
import 'package:flutter_login_google/core/error/failure.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts({required int page, required int limit});
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final http.Client _client;
  static const Map<String, String> _defaultHeaders = <String, String>{
    'User-Agent': 'Mozilla/5.0',
    'Accept': 'application/json',
  };

  PostRemoteDataSourceImpl({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<PostModel>> getPosts({
    required int page,
    required int limit,
  }) async {
    try {
      final baseUri = Uri.parse(ApiConstants.jsonPlaceholderBaseUrl);
      final uri = Uri.parse(
        baseUri
            .resolve(ApiConstants.posts)
            .replace(queryParameters: <String, String>{
          '_page': '$page',
          '_limit': '$limit',
        }).toString(),
      );
      final response = await _client.get(uri, headers: _defaultHeaders);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body) as List;
        return jsonList
            .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerFailure(
          'Failed to load posts: ${response.statusCode}',
        );
      }
    } on ServerFailure {
      rethrow;
    } catch (e) {
      // Re-throw to be handled by repository
      rethrow;
    }
  }
}
