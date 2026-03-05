import 'package:flutter/material.dart';

import '../models/post.dart';

/// A single card in the posts list.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.index = 0,
  });

  final Post post;
  final VoidCallback onTap;
  final int index;

  // Cycles through a palette of accent colours for visual variety.
  static const List<Color> _accents = [
    Color(0xFF1565C0),
    Color(0xFF00897B),
    Color(0xFF6A1B9A),
    Color(0xFFE65100),
    Color(0xFF283593),
    Color(0xFF00695C),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _accents[index % _accents.length];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(80)
                : Colors.black.withAlpha(18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: accent.withAlpha(30),
            highlightColor: accent.withAlpha(15),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Left accent bar ─────────────────────────────────
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [accent, accent.withAlpha(120)],
                      ),
                    ),
                  ),

                  // ── Card content ────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: user badge + post number
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: accent.withAlpha(isDark ? 50 : 25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person_rounded,
                                        size: 11, color: accent),
                                    const SizedBox(width: 3),
                                    Text(
                                      'User ${post.userId}',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: accent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '#${post.id}',
                                style: textTheme.labelSmall?.copyWith(
                                  color: cs.onSurface.withAlpha(80),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 9),

                          // Title
                          Text(
                            post.title,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                              color: cs.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 6),

                          // Body preview
                          Text(
                            post.body,
                            style: textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withAlpha(140),
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 10),

                          // Footer row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest
                                      .withAlpha(isDark ? 60 : 100),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Tap to read',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: cs.onSurface.withAlpha(120),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                                color: accent.withAlpha(180),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
