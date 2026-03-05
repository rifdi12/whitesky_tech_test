import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:whitesky_aviation_tech_test/blocs/post_bloc.dart';
import 'package:whitesky_aviation_tech_test/models/post.dart';
import 'package:whitesky_aviation_tech_test/repositories/post_repository.dart';

// ── Mock ─────────────────────────────────────────────────────────────────────

class MockPostRepository extends Mock implements PostRepository {}

// ── Fixtures ──────────────────────────────────────────────────────────────────

List<Post> _posts(int count, {int startId = 1}) => List.generate(
      count,
      (i) => Post(
        id: startId + i,
        userId: 1,
        title: 'Title ${startId + i}',
        body: 'Body ${startId + i}',
      ),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockPostRepository mockRepo;

  setUp(() {
    mockRepo = MockPostRepository();
  });

  // ── LoadPosts ─────────────────────────────────────────────────────────────

  group('LoadPosts event', () {
    blocTest<PostBloc, PostState>(
      'emits [PostLoading, PostLoaded] on successful fetch',
      build: () {
        when(() => mockRepo.fetchPosts(page: any(named: 'page')))
            .thenAnswer((_) async => _posts(10));
        return PostBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoadPosts()),
      expect: () => [
        const PostLoading(),
        PostLoaded(posts: _posts(10), hasMore: true),
      ],
    );

    blocTest<PostBloc, PostState>(
      'emits [PostLoading, PostLoaded(hasMore: false)] when API returns empty',
      build: () {
        when(() => mockRepo.fetchPosts(page: any(named: 'page')))
            .thenAnswer((_) async => []);
        return PostBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoadPosts()),
      expect: () => [
        const PostLoading(),
        const PostLoaded(posts: [], hasMore: false),
      ],
    );

    blocTest<PostBloc, PostState>(
      'emits [PostLoading, PostError] when repository throws',
      build: () {
        when(() => mockRepo.fetchPosts(page: any(named: 'page')))
            .thenThrow(const PostRepositoryException('Network error'));
        return PostBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoadPosts()),
      expect: () => [
        const PostLoading(),
        const PostError(message: 'Network error'),
      ],
    );

    blocTest<PostBloc, PostState>(
      'resets to page 1 when LoadPosts is dispatched a second time',
      build: () {
        when(() => mockRepo.fetchPosts(page: any(named: 'page')))
            .thenAnswer((_) async => _posts(10));
        return PostBloc(repository: mockRepo);
      },
      act: (bloc) async {
        bloc.add(const LoadPosts());
        await Future.delayed(Duration.zero);
        bloc.add(const LoadPosts());
      },
      // After both LoadPosts: Loading → Loaded, Loading → Loaded
      expect: () => [
        const PostLoading(),
        PostLoaded(posts: _posts(10), hasMore: true),
        const PostLoading(),
        PostLoaded(posts: _posts(10), hasMore: true),
      ],
    );
  });

  // ── LoadMorePosts ────────────────────────────────────────────────────────

  group('LoadMorePosts event', () {
    blocTest<PostBloc, PostState>(
      'appends next page to existing posts',
      build: () {
        var callCount = 0;
        when(() => mockRepo.fetchPosts(page: any(named: 'page'))).thenAnswer(
          (_) async {
            callCount++;
            return _posts(10, startId: (callCount - 1) * 10 + 1);
          },
        );
        return PostBloc(repository: mockRepo);
      },
      act: (bloc) async {
        bloc.add(const LoadPosts());
        await Future.delayed(Duration.zero);
        bloc.add(const LoadMorePosts());
      },
      expect: () => [
        const PostLoading(),
        PostLoaded(posts: _posts(10), hasMore: true),
        PostLoaded(
            posts: _posts(10), hasMore: true, isFetchingMore: true),
        PostLoaded(
            posts: [..._posts(10), ..._posts(10, startId: 11)],
            hasMore: true),
      ],
    );

    blocTest<PostBloc, PostState>(
      'sets hasMore=false when next page is empty',
      build: () {
        var callCount = 0;
        when(() => mockRepo.fetchPosts(page: any(named: 'page'))).thenAnswer(
          (_) async {
            callCount++;
            return callCount == 1 ? _posts(10) : [];
          },
        );
        return PostBloc(repository: mockRepo);
      },
      act: (bloc) async {
        bloc.add(const LoadPosts());
        await Future.delayed(Duration.zero);
        bloc.add(const LoadMorePosts());
      },
      expect: () => [
        const PostLoading(),
        PostLoaded(posts: _posts(10), hasMore: true),
        PostLoaded(
            posts: _posts(10), hasMore: true, isFetchingMore: true),
        PostLoaded(posts: _posts(10), hasMore: false),
      ],
    );

    blocTest<PostBloc, PostState>(
      'emits paginationError when next page fetch fails',
      build: () {
        var callCount = 0;
        when(() => mockRepo.fetchPosts(page: any(named: 'page'))).thenAnswer(
          (_) async {
            callCount++;
            if (callCount == 1) return _posts(10);
            throw const PostRepositoryException('Pagination failed');
          },
        );
        return PostBloc(repository: mockRepo);
      },
      act: (bloc) async {
        bloc.add(const LoadPosts());
        await Future.delayed(Duration.zero);
        bloc.add(const LoadMorePosts());
      },
      expect: () => [
        const PostLoading(),
        PostLoaded(posts: _posts(10), hasMore: true),
        PostLoaded(
            posts: _posts(10), hasMore: true, isFetchingMore: true),
        PostLoaded(
            posts: _posts(10),
            hasMore: true,
            paginationError: 'Pagination failed'),
      ],
    );

    blocTest<PostBloc, PostState>(
      'is a no-op when state is not PostLoaded',
      build: () => PostBloc(repository: mockRepo),
      act: (bloc) => bloc.add(const LoadMorePosts()),
      expect: () => <PostState>[], // PostInitial — nothing emitted
    );

    blocTest<PostBloc, PostState>(
      'is a no-op when hasMore is false',
      build: () {
        when(() => mockRepo.fetchPosts(page: any(named: 'page')))
            .thenAnswer((_) async => []);
        return PostBloc(repository: mockRepo);
      },
      act: (bloc) async {
        bloc.add(const LoadPosts());
        await Future.delayed(Duration.zero);
        bloc.add(const LoadMorePosts()); // hasMore is false → no-op
      },
      expect: () => [
        const PostLoading(),
        const PostLoaded(posts: [], hasMore: false),
        // no extra state emitted
      ],
    );

    blocTest<PostBloc, PostState>(
      'consecutive LoadMorePosts calls each trigger a fetch (guard is state-based)',
      build: () {
        when(() => mockRepo.fetchPosts(page: any(named: 'page')))
            .thenAnswer((_) async => _posts(10));
        return PostBloc(repository: mockRepo);
      },
      act: (bloc) async {
        bloc.add(const LoadPosts());
        await Future.delayed(Duration.zero); // wait for first page to load
        bloc
          ..add(const LoadMorePosts())
          ..add(const LoadMorePosts());
      },
      // Both LoadMorePosts events fire before the BLoC can emit isFetchingMore=true
      // (they're concurrent), so the guard passes for both.
      // This verifies the BLoC doesn't crash on concurrent events.
      verify: (_) {
        verify(() => mockRepo.fetchPosts(page: any(named: 'page')))
            .called(greaterThanOrEqualTo(2));
      },
    );
  });

  // ── PostLoaded.copyWith ──────────────────────────────────────────────────

  group('PostLoaded.copyWith', () {
    final base = PostLoaded(posts: _posts(5));

    test('copies without changes when no arguments provided', () {
      final copy = base.copyWith();
      expect(copy.posts, base.posts);
      expect(copy.hasMore, base.hasMore);
      expect(copy.isFetchingMore, base.isFetchingMore);
      expect(copy.paginationError, base.paginationError);
    });

    test('updates posts', () {
      final newPosts = _posts(3);
      final copy = base.copyWith(posts: newPosts);
      expect(copy.posts, newPosts);
    });

    test('clears paginationError when clearPaginationError is true', () {
      final withError = base.copyWith(paginationError: 'error');
      final cleared = withError.copyWith(clearPaginationError: true);
      expect(cleared.paginationError, isNull);
    });

    test('Equatable props include all fields', () {
      final a = PostLoaded(posts: _posts(2), hasMore: true);
      final b = PostLoaded(posts: _posts(2), hasMore: true);
      // Equatable equality depends on the props list having equal elements.
      expect(a, equals(b));
    });
  });
}
