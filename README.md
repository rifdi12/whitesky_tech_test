# Posts Browser – Whitesky Aviation Tech Test

A Flutter application that fetches posts from the [JSONPlaceholder](https://jsonplaceholder.typicode.com/posts) public REST API, displays them in a paginated scrollable list, and lets users tap a post to view its full details.

---

## How to Run

### Prerequisites

| Tool | Version |
|---|---|
| Flutter SDK | ≥ 3.x (latest stable) |
| Dart SDK | ≥ 3.x |
| Android Studio / Xcode | for device/simulator |

### Steps

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd whitesky_aviation_tech_test

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or simulator
flutter run
```

> **Note:** The app requires an active internet connection to fetch posts from the JSONPlaceholder API.

---

## Architectural Approach

The project follows a **layered architecture** that cleanly separates data, business logic, and UI concerns.

```
lib/
├── main.dart                    ← App entry point & BlocProvider setup
├── models/
│   └── post.dart                ← Immutable Post data class
├── repositories/
│   └── post_repository.dart     ← Network layer – wraps http calls, handles errors
├── blocs/
│   ├── post_bloc.dart           ← Business logic (Bloc<PostEvent, PostState>)
│   ├── post_event.dart          ← LoadPosts, LoadMorePosts events
│   └── post_state.dart          ← PostInitial, PostLoading, PostLoaded, PostError
├── screens/
│   ├── post_list_screen.dart    ← Paginated list screen
│   └── post_detail_screen.dart  ← Detail screen
└── widgets/
    ├── post_card.dart               ← Reusable list-item card
    ├── loading_state_widget.dart    ← Skeleton placeholder
    ├── error_state_widget.dart      ← Error + retry button
    └── empty_state_widget.dart      ← Empty list message
```

### State Management – flutter_bloc (BLoC pattern)

**Choice:** `flutter_bloc` package using a `Bloc<PostEvent, PostState>` class.

**Why BLoC?**
- Events and states are **explicit, typed, and immutable** – the full history of what happened and what the UI should show is always traceable.
- Business logic is completely **decoupled from the widget tree**; `PostBloc` has zero Flutter dependencies and is trivially unit-testable.
- `Equatable` prevents redundant rebuilds: `BlocBuilder` only re-renders when the state value actually changes.
- Scales naturally to more complex flows (e.g. adding search, filters) without refactoring the widget layer.

### Pagination Strategy

- `PostProvider` tracks a `_currentPage` counter and a `_hasMore` flag.
- `PostListScreen` attaches a `ScrollController` and calls `loadMorePosts()` when the user scrolls within 200 px of the bottom.
- A sentinel item at the end of the `ListView` shows either a `CircularProgressIndicator` (while loading the next page) or an "End of posts" label (when `_hasMore == false`).

---

## States Handled

| State | How it's displayed |
|---|---|
| **Loading (initial)** | Skeleton card placeholders fill the screen |
| **Loading (paginating)** | `CircularProgressIndicator` at the bottom of the list |
| **Success** | Scrollable list of `PostCard` widgets |
| **Error (initial load)** | Centred icon + message + **Retry** button |
| **Error (pagination)** | Silently stops; user can pull-to-refresh |
| **Empty** | Centred inbox icon + "No posts found." message |

---

## Assumptions Made

1. **Page size is 10** – JSONPlaceholder supports `_limit` / `_page` query params; the API has exactly 100 posts so the list naturally ends after 10 pages.
2. **No caching** – Data is re-fetched on every cold start or explicit refresh (pull-to-refresh / AppBar refresh button). Adding a local cache (e.g. Hive or sqflite) is straightforward but out of scope.
3. **No authentication** – JSONPlaceholder is a public read-only API.
4. **Material 3 design** – The app uses Material 3 with a dynamic `ColorScheme` and respects the system dark/light theme.
5. **Navigation is push-based** – Simple `Navigator.push` is sufficient; a named-route or GoRouter setup would be appropriate for a larger app with deep-linking needs.

---

## Dependencies

| Package | Purpose |
|---|---|
| [`http`](https://pub.dev/packages/http) | HTTP client for REST API calls |
| [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) | State management (BLoC pattern) |
| [`equatable`](https://pub.dev/packages/equatable) | Value equality for BLoC states & events |

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
