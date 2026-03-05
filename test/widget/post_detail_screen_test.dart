import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitesky_aviation_tech_test/models/post.dart';
import 'package:whitesky_aviation_tech_test/screens/post_detail_screen.dart';

Widget _buildScreen(Post post) {
  return MaterialApp(home: PostDetailScreen(post: post));
}

void main() {
  const post = Post(
    id: 3,
    userId: 7,
    title: 'Detail Screen Title',
    body: 'Full body content shown in the detail view.',
  );

  group('PostDetailScreen', () {
    testWidgets('renders post title', (tester) async {
      await tester.pumpWidget(_buildScreen(post));
      await tester.pumpAndSettle();

      expect(find.text('Detail Screen Title'), findsWidgets);
    });

    testWidgets('renders post body', (tester) async {
      await tester.pumpWidget(_buildScreen(post));
      await tester.pumpAndSettle();

      expect(find.text('Full body content shown in the detail view.'),
          findsOneWidget);
    });

    testWidgets('renders user id label', (tester) async {
      await tester.pumpWidget(_buildScreen(post));
      await tester.pumpAndSettle();

      // The detail screen shows "User 7" or "Author" chip containing user id
      expect(find.textContaining('7'), findsWidgets);
    });

    testWidgets('renders post id chip', (tester) async {
      await tester.pumpWidget(_buildScreen(post));
      await tester.pumpAndSettle();

      expect(find.textContaining('3'), findsWidgets);
    });

    testWidgets('back button pops the route', (tester) async {
      bool popped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(post: post),
                  ),
                );
              },
              child: const Text('Go'),
            ),
          ),
          navigatorObservers: [
            _Popped(onPop: () => popped = true),
          ],
        ),
      );

      // Navigate to detail screen
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      // Tap the custom back button (IconButton with arrow_back_rounded)
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });
  });
}

// ── Observer ─────────────────────────────────────────────────────────────────

class _Popped extends NavigatorObserver {
  _Popped({required this.onPop});
  final VoidCallback onPop;

  @override
  void didPop(Route route, Route? previousRoute) {
    onPop();
  }
}
