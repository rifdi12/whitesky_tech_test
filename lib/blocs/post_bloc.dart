import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/post.dart';
import '../repositories/post_repository.dart';

part 'post_event.dart';
part 'post_state.dart';

/// Handles all post-list business logic.
///
/// Events → States:
///   [LoadPosts]     → [PostLoading] → [PostLoaded] | [PostError]
///   [LoadMorePosts] → [PostLoaded(isFetchingMore: true)] → [PostLoaded] (appended)
class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({PostRepository? repository})
    : _repository = repository ?? PostRepository(),
      super(const PostInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<LoadMorePosts>(_onLoadMorePosts);
  }

  final PostRepository _repository;
  int _currentPage = 1;

  // ── Event handlers ───────────────────────────────────────────────────────

  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    emit(const PostLoading());
    _currentPage = 1;

    try {
      final posts = await _repository.fetchPosts(page: _currentPage);
      _currentPage++;
      // If the first page is already smaller than pageSize there are no more pages.
      final hasMore = posts.length >= PostRepository.pageSize;
      emit(PostLoaded(posts: posts, hasMore: hasMore));
    } on PostRepositoryException catch (e) {
      emit(PostError(message: e.message));
    }
  }

  Future<void> _onLoadMorePosts(
    LoadMorePosts event,
    Emitter<PostState> emit,
  ) async {
    final current = state;
    if (current is! PostLoaded) return;
    if (!current.hasMore || current.isFetchingMore) return;

    emit(current.copyWith(isFetchingMore: true, clearPaginationError: true));

    try {
      final newPosts = await _repository.fetchPosts(page: _currentPage);

      // A partial page (or empty page) signals the end of the data set.
      final hasMore = newPosts.length >= PostRepository.pageSize;

      _currentPage++;
      emit(
        current.copyWith(
          posts: [...current.posts, ...newPosts],
          hasMore: hasMore,
          isFetchingMore: false,
        ),
      );
    } on PostRepositoryException catch (e) {
      emit(current.copyWith(isFetchingMore: false, paginationError: e.message));
    }
  }
}
