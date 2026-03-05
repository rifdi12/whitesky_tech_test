import 'package:flutter_test/flutter_test.dart';
import 'package:whitesky_aviation_tech_test/models/post.dart';

void main() {
  group('Post model', () {
    const tPost = Post(id: 1, userId: 2, title: 'Test Title', body: 'Test body');

    const tJson = <String, dynamic>{
      'id': 1,
      'userId': 2,
      'title': 'Test Title',
      'body': 'Test body',
    };

    // ── fromJson ──────────────────────────────────────────────────────────

    group('fromJson', () {
      test('creates a Post from a valid JSON map', () {
        final result = Post.fromJson(tJson);

        expect(result.id, 1);
        expect(result.userId, 2);
        expect(result.title, 'Test Title');
        expect(result.body, 'Test body');
      });

      test('maps all fields correctly when values differ', () {
        final json = <String, dynamic>{
          'id': 99,
          'userId': 10,
          'title': 'Another title',
          'body': 'Another body',
        };
        final post = Post.fromJson(json);

        expect(post.id, 99);
        expect(post.userId, 10);
        expect(post.title, 'Another title');
        expect(post.body, 'Another body');
      });
    });

    // ── toString ─────────────────────────────────────────────────────────

    group('toString', () {
      test('returns a readable string representation', () {
        expect(
          tPost.toString(),
          'Post(id: 1, userId: 2, title: Test Title)',
        );
      });
    });

    // ── Value equality ────────────────────────────────────────────────────

    group('equality', () {
      test('two Posts with identical fields are equal via ==', () {
        const a = Post(id: 1, userId: 2, title: 'T', body: 'B');
        const b = Post(id: 1, userId: 2, title: 'T', body: 'B');

        // Post is a plain Dart class with const constructor; identical objects
        // are equal by identity.
        expect(identical(a, b), isTrue);
      });

      test('Posts with different ids are not identical', () {
        const a = Post(id: 1, userId: 1, title: 'T', body: 'B');
        const b = Post(id: 2, userId: 1, title: 'T', body: 'B');

        expect(identical(a, b), isFalse);
      });
    });

    // ── Field assertions ──────────────────────────────────────────────────

    test('holds all four fields correctly', () {
      expect(tPost.id, 1);
      expect(tPost.userId, 2);
      expect(tPost.title, 'Test Title');
      expect(tPost.body, 'Test body');
    });
  });
}
