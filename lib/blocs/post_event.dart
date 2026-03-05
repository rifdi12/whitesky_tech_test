part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered on first load or pull-to-refresh.
class LoadPosts extends PostEvent {
  const LoadPosts();
}

/// Triggered when the user scrolls near the bottom of the list.
class LoadMorePosts extends PostEvent {
  const LoadMorePosts();
}
