// Smoke test — verifies the app can boot and render PostListScreen.
// Individual unit, bloc, and widget tests live in test/unit/, test/bloc/,
// and test/widget/ respectively.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:whitesky_aviation_tech_test/blocs/post_bloc.dart';
import 'package:whitesky_aviation_tech_test/models/post.dart';
import 'package:whitesky_aviation_tech_test/repositories/post_repository.dart';
import 'package:whitesky_aviation_tech_test/screens/post_list_screen.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  testWidgets('App boots and renders PostListScreen', (tester) async {
    final repo = MockPostRepository();
    when(() => repo.fetchPosts(page: any(named: 'page'))).thenAnswer(
      (_) async => List.generate(
        3,
        (i) => Post(id: i + 1, userId: 1, title: 'Title ${i + 1}', body: 'B'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => PostBloc(repository: repo)..add(const LoadPosts()),
          child: const PostListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(PostListScreen), findsOneWidget);
  });
}
