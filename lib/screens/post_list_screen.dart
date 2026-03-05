import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/post_bloc.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/loading_state_widget.dart';
import '../widgets/post_card.dart';
import 'post_detail_screen.dart';

/// The main screen that shows the paginated list of posts.
class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<PostBloc>().add(const LoadMorePosts());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ── Gradient SliverAppBar ─────────────────────────────────
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Posts Browser',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withAlpha(80),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      if (state is PostLoaded)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${state.posts.length} posts loaded',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFF1A2744),
                                const Color(0xFF0D1B2A),
                              ]
                            : [
                                const Color(0xFF1565C0),
                                const Color(0xFF42A5F5),
                              ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -30,
                          top: -20,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withAlpha(15),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 40,
                          bottom: -10,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withAlpha(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded,
                        color: Colors.white),
                    tooltip: 'Refresh',
                    onPressed: () =>
                        context.read<PostBloc>().add(const LoadPosts()),
                  ),
                  const SizedBox(width: 4),
                ],
              ),

              // ── Body content ──────────────────────────────────────────
              if (state is PostInitial || state is PostLoading)
                const SliverFillRemaining(child: LoadingStateWidget()),

              if (state is PostError)
                SliverFillRemaining(
                  child: ErrorStateWidget(
                    message: state.message,
                    onRetry: () =>
                        context.read<PostBloc>().add(const LoadPosts()),
                  ),
                ),

              if (state is PostLoaded) ...[
                if (state.posts.isEmpty)
                  const SliverFillRemaining(child: EmptyStateWidget()),

                if (state.posts.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    sliver: SliverList.builder(
                      itemCount: state.posts.length,
                      itemBuilder: (context, index) {
                        final post = state.posts[index];
                        return PostCard(
                          post: post,
                          index: index,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostDetailScreen(post: post),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ── Pagination footer ─────────────────────────────────
                  SliverToBoxAdapter(
                    child: _PaginationFooter(state: state, cs: cs),
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({required this.state, required this.cs});

  final PostLoaded state;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    if (state.isFetchingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2.5, color: cs.primary),
        ),
      );
    }

    if (!state.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Divider(
                  indent: 40, endIndent: 12, color: cs.outlineVariant),
            ),
            Text(
              '  All posts loaded  ',
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withAlpha(100),
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Divider(
                  indent: 12, endIndent: 40, color: cs.outlineVariant),
            ),
          ],
        ),
      );
    }

    if (state.paginationError != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: cs.onErrorContainer, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                state.paginationError!,
                style: TextStyle(color: cs.onErrorContainer, fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: () =>
                  context.read<PostBloc>().add(const LoadMorePosts()),
              child: Text(
                'Retry',
                style: TextStyle(
                    color: cs.onErrorContainer, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
