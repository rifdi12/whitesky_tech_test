part of 'post_bloc.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

/// Before any data has been requested.
class PostInitial extends PostState {
  const PostInitial();
}

/// First-page fetch is in progress.
class PostLoading extends PostState {
  const PostLoading();
}

/// At least one page has loaded successfully.
class PostLoaded extends PostState {
  const PostLoaded({
    required this.posts,
    this.hasMore = true,
    this.isFetchingMore = false,
    this.paginationError,
  });

  final List<Post> posts;

  /// Whether there are more pages to fetch from the API.
  final bool hasMore;

  /// True while a subsequent page is being appended.
  final bool isFetchingMore;

  /// Non-null when a pagination request failed (initial state is still shown).
  final String? paginationError;

  PostLoaded copyWith({
    List<Post>? posts,
    bool? hasMore,
    bool? isFetchingMore,
    String? paginationError,
    bool clearPaginationError = false,
  }) {
    return PostLoaded(
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      paginationError: clearPaginationError
          ? null
          : (paginationError ?? this.paginationError),
    );
  }

  @override
  List<Object?> get props => [posts, hasMore, isFetchingMore, paginationError];
}

/// First-page fetch failed.
class PostError extends PostState {
  const PostError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
