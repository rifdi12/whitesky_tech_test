import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:whitesky_aviation_tech_test/blocs/post_bloc.dart';
import 'package:whitesky_aviation_tech_test/models/post.dart';
import 'package:whitesky_aviation_tech_test/repositories/post_repository.dart';
import 'package:whitesky_aviation_tech_test/screens/post_list_screen.dart';
import 'package:whitesky_aviation_tech_test/widgets/empty_state_widget.dart';
import 'package:whitesky_aviation_tech_test/widgets/error_state_widget.dart';
import 'package:whitesky_aviation_tech_test/widgets/loading_state_widget.dart';
import 'package:whitesky_aviation_tech_test/widgets/post_card.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────

class MockPostRepository extends Mock implements PostRepository {}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// A full page (== PostRepository.pageSize) → hasMore: true after load.
List<Post> _fullPage() => List.generate(
  PostRepository.pageSize,
  (i) => Post(
    id: i + 1,
    userId: 1,
    title: 'Post Title ${i + 1}',
    body: 'Post body ${i + 1}',
  ),
);

/// A partial page (< PostRepository.pageSize) → hasMore: false after load.
List<Post> _posts(int count) => List.generate(
  count,
  (i) => Post(
    id: i + 1,
    userId: 1,
    title: 'Post Title ${i + 1}',
    body: 'Post body ${i + 1}',
  ),
);

/// Wraps [PostListScreen] inside a [BlocProvider] backed by a real [PostBloc]
/// that uses [mockRepo].
Widget _buildScreen(MockPostRepository mockRepo) {
  return MaterialApp(
    home: BlocProvider(
      create: (_) => PostBloc(repository: mockRepo)..add(const LoadPosts()),
      child: const PostListScreen(),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockPostRepository mockRepo;

  setUp(() {
    mockRepo = MockPostRepository();
  });

  group('PostListScreen', () {
    testWidgets('shows loading widget while fetching first page', (
      tester,
    ) async {
      // Use a Completer so the future never resolves during this test,
      // and we can complete it before teardown to avoid pending-timer warnings.
      final completer = Completer<List<Post>>();
      when(
        () => mockRepo.fetchPosts(page: any(named: 'page')),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(_buildScreen(mockRepo));
      await tester.pump(); // let BLoC emit PostLoading

      expect(find.byType(LoadingStateWidget), findsOneWidget);

      // Complete before the test ends to avoid dangling futures.
      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('shows list of PostCards when posts load', (tester) async {
      when(
        () => mockRepo.fetchPosts(page: any(named: 'page')),
      ).thenAnswer((_) async => _fullPage());

      await tester.pumpWidget(_buildScreen(mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(PostCard), findsWidgets);
      // First post should be visible in the viewport
      expect(find.text('Post Title 1'), findsOneWidget);
    });

    testWidgets('shows empty state widget when API returns no posts', (
      tester,
    ) async {
      when(
        () => mockRepo.fetchPosts(page: any(named: 'page')),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildScreen(mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });

    testWidgets('shows error state widget when repository throws', (
      tester,
    ) async {
      when(
        () => mockRepo.fetchPosts(page: any(named: 'page')),
      ).thenThrow(const PostRepositoryException('Something went wrong'));

      await tester.pumpWidget(_buildScreen(mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorStateWidget), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('retry button in ErrorStateWidget re-dispatches LoadPosts', (
      tester,
    ) async {
      var callCount = 0;
      when(() => mockRepo.fetchPosts(page: any(named: 'page'))).thenAnswer((
        _,
      ) async {
        callCount++;
        if (callCount == 1) {
          throw const PostRepositoryException('Network error');
        }
        return _posts(3);
      });

      await tester.pumpWidget(_buildScreen(mockRepo));
      await tester.pumpAndSettle();

      // First call → error state
      expect(find.byType(ErrorStateWidget), findsOneWidget);

      // Tap the retry icon inside ErrorStateWidget
      await tester.tap(
        find.descendant(
          of: find.byType(ErrorStateWidget),
          matching: find.byIcon(Icons.refresh_rounded),
        ),
      );
      await tester.pumpAndSettle();

      // Second call → success
      expect(find.byType(PostCard), findsWidgets);
    });

    testWidgets('displays post count chip when posts are loaded', (
      tester,
    ) async {
      when(
        () => mockRepo.fetchPosts(page: any(named: 'page')),
      ).thenAnswer((_) async => _posts(4));

      await tester.pumpWidget(_buildScreen(mockRepo));
      await tester.pumpAndSettle();

      expect(find.textContaining('4'), findsWidgets);
    });

    testWidgets('tapping a PostCard navigates to detail screen', (
      tester,
    ) async {
      when(
        () => mockRepo.fetchPosts(page: any(named: 'page')),
      ).thenAnswer((_) async => _posts(2));

      await tester.pumpWidget(_buildScreen(mockRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PostCard).first);
      await tester.pumpAndSettle();

      // Detail screen shows the tapped post's title
      expect(find.text('Post Title 1'), findsWidgets);
    });
  });
}
