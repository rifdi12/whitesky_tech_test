import 'package:flutter/material.dart';

/// Shown when the list is successfully loaded but contains no items.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key, this.message = 'No posts found.'});

  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.surfaceContainerHighest.withAlpha(100),
              ),
              child: Icon(
                Icons.inbox_rounded,
                size: 54,
                color: cs.onSurface.withAlpha(100),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Nothing Here Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withAlpha(150),
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
