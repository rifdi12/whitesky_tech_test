import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/post.dart';

/// Handles all network communication with the JSONPlaceholder API.
/// Supports paginated fetching via [pageSize] items per request.
class PostRepository {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const int pageSize = 10;

  final http.Client _client;

  PostRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches a page of posts using offset-based pagination.
  ///
  /// [page] is 1-based. Uses JSONPlaceholder's `_start` / `_limit` params.
  /// Returns an empty list when there are no more items.
  /// Throws a [PostRepositoryException] on network or parsing failure.
  Future<List<Post>> fetchPosts({required int page}) async {
    final start = (page - 1) * pageSize;
    final uri = Uri.parse('$_baseUrl/posts').replace(
      queryParameters: {
        '_start': '$start',
        '_limit': '$pageSize',
      },
    );

    try {
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body) as List;
        return jsonList
            .map((e) => Post.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw PostRepositoryException(
          'Server returned status ${response.statusCode}',
        );
      }
    } on SocketException {
      throw PostRepositoryException(
        'No internet connection. Please check your network and try again.',
      );
    } on FormatException {
      throw PostRepositoryException('Failed to parse server response.');
    } on PostRepositoryException {
      rethrow;
    } catch (e) {
      throw PostRepositoryException('An unexpected error occurred: $e');
    }
  }
}

/// Typed exception thrown by [PostRepository].
class PostRepositoryException implements Exception {
  final String message;
  const PostRepositoryException(this.message);

  @override
  String toString() => 'PostRepositoryException: $message';
}
