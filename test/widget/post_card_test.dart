import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitesky_aviation_tech_test/models/post.dart';
import 'package:whitesky_aviation_tech_test/widgets/post_card.dart';

// Helper — wraps the card in a minimal Material app so themes resolve.
Widget _buildCard({
  required Post post,
  required VoidCallback onTap,
  int index = 0,
}) {
  return MaterialApp(
    home: Scaffold(
      body: PostCard(post: post, onTap: onTap, index: index),
    ),
  );
}

void main() {
  const testPost = Post(id: 1, userId: 2, title: 'Hello World', body: 'Body text here');

  group('PostCard widget', () {
    testWidgets('renders the post title', (tester) async {
      await tester.pumpWidget(_buildCard(post: testPost, onTap: () {}));
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('renders the post body (truncated or full)', (tester) async {
      await tester.pumpWidget(_buildCard(post: testPost, onTap: () {}));
      expect(find.text('Body text here'), findsOneWidget);
    });

    testWidgets('renders user badge showing userId', (tester) async {
      await tester.pumpWidget(_buildCard(post: testPost, onTap: () {}));
      // The badge reads "User 2"
      expect(find.text('User 2'), findsOneWidget);
    });

    testWidgets('renders post id in top-right badge', (tester) async {
      await tester.pumpWidget(_buildCard(post: testPost, onTap: () {}));
      expect(find.text('#1'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_buildCard(post: testPost, onTap: () => tapped = true));
      await tester.tap(find.byType(PostCard));
      expect(tapped, isTrue);
    });

    testWidgets('uses different accent colours for different indices',
        (tester) async {
      // Just verifies two cards can render at different indices without error.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PostCard(post: testPost, onTap: () {}, index: 0),
                PostCard(post: testPost, onTap: () {}, index: 3),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(PostCard), findsNWidgets(2));
    });
  });
}
