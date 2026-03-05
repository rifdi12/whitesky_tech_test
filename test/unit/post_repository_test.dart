import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:whitesky_aviation_tech_test/repositories/post_repository.dart';

// ── Mock ────────────────────────────────────────────────────────────────────

class MockHttpClient extends Mock implements http.Client {}

// ── Helpers ──────────────────────────────────────────────────────────────────

String _postJson({int id = 1, int userId = 1}) => jsonEncode([
  {'id': id, 'userId': userId, 'title': 'Title $id', 'body': 'Body $id'},
]);

String _multiplePostsJson(int count) => jsonEncode(
  List.generate(
    count,
    (i) => {
      'id': i + 1,
      'userId': 1,
      'title': 'Title ${i + 1}',
      'body': 'Body ${i + 1}',
    },
  ),
);

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late MockHttpClient mockClient;
  late PostRepository repository;

  setUp(() {
    mockClient = MockHttpClient();
    repository = PostRepository(client: mockClient);
    // Register default fallback for Uri arguments used with mocktail
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  group('PostRepository.fetchPosts', () {
    // ── Pagination query params ──────────────────────────────────────────

    test('sends correct _start and _limit query params for page 1', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(_postJson(), 200));

      await repository.fetchPosts(page: 1);

      final captured = verify(
        () => mockClient.get(captureAny()),
      ).captured.single as Uri;

      expect(captured.queryParameters['_start'], '0');
      expect(captured.queryParameters['_limit'], '${PostRepository.pageSize}');
    });

    test('sends correct _start for page 2', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(_postJson(), 200));

      await repository.fetchPosts(page: 2);

      final captured = verify(
        () => mockClient.get(captureAny()),
      ).captured.single as Uri;

      expect(
        captured.queryParameters['_start'],
        '${PostRepository.pageSize}',
      );
    });

    // ── Success ─────────────────────────────────────────────────────────

    test('returns a list of Posts on HTTP 200', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(_postJson(), 200));

      final posts = await repository.fetchPosts(page: 1);

      expect(posts, hasLength(1));
      expect(posts.first.id, 1);
      expect(posts.first.title, 'Title 1');
    });

    test('returns multiple posts parsed correctly', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(_multiplePostsJson(5), 200));

      final posts = await repository.fetchPosts(page: 1);

      expect(posts, hasLength(5));
      for (var i = 0; i < 5; i++) {
        expect(posts[i].id, i + 1);
      }
    });

    test('returns empty list when server returns empty array', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response('[]', 200));

      final posts = await repository.fetchPosts(page: 1);

      expect(posts, isEmpty);
    });

    // ── HTTP error ───────────────────────────────────────────────────────

    test('throws PostRepositoryException on HTTP 404', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
        () => repository.fetchPosts(page: 1),
        throwsA(
          isA<PostRepositoryException>().having(
            (e) => e.message,
            'message',
            contains('404'),
          ),
        ),
      );
    });

    test('throws PostRepositoryException on HTTP 500', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response('Internal Server Error', 500));

      expect(
        () => repository.fetchPosts(page: 1),
        throwsA(isA<PostRepositoryException>()),
      );
    });

    // ── Network errors ───────────────────────────────────────────────────

    test(
      'throws PostRepositoryException on SocketException (no internet)',
      () async {
        when(
          () => mockClient.get(any()),
        ).thenThrow(const SocketException('No internet'));

        expect(
          () => repository.fetchPosts(page: 1),
          throwsA(
            isA<PostRepositoryException>().having(
              (e) => e.message,
              'message',
              contains('No internet connection'),
            ),
          ),
        );
      },
    );

    test(
      'throws PostRepositoryException on FormatException (bad JSON)',
      () async {
        when(
          () => mockClient.get(any()),
        ).thenAnswer((_) async => http.Response('not-valid-json', 200));

        expect(
          () => repository.fetchPosts(page: 1),
          throwsA(
            isA<PostRepositoryException>().having(
              (e) => e.message,
              'message',
              contains('parse'),
            ),
          ),
        );
      },
    );

    test('throws PostRepositoryException on unexpected error', () async {
      when(() => mockClient.get(any())).thenThrow(Exception('Unknown'));

      expect(
        () => repository.fetchPosts(page: 1),
        throwsA(isA<PostRepositoryException>()),
      );
    });
  });

  // ── PostRepositoryException ──────────────────────────────────────────────

  group('PostRepositoryException', () {
    test('toString includes the message', () {
      const ex = PostRepositoryException('test error');
      expect(ex.toString(), contains('test error'));
    });
  });
}
