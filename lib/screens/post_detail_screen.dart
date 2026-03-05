import 'package:flutter/material.dart';

import '../models/post.dart';

/// Shows the full content of a single [Post].
class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key, required this.post});

  final Post post;

  // Same accent palette as PostCard
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _accents[(post.id - 1) % _accents.length];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Gradient SliverAppBar ───────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white.withAlpha(30),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            accent.withAlpha(180),
                            const Color(0xFF0D1B2A),
                          ]
                        : [
                            accent,
                            accent.withAlpha(160),
                          ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      right: -40,
                      top: -40,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(12),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(8),
                        ),
                      ),
                    ),
                    // Post number pill
                    Positioned(
                      right: 20,
                      bottom: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withAlpha(60), width: 1),
                        ),
                        child: Text(
                          'Post #${post.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // Large avatar centred vertically
                    Positioned(
                      left: 24,
                      bottom: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white.withAlpha(40),
                            child: Text(
                              '${post.userId}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'User #${post.userId}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Author',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(180),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info chips row
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.tag_rounded,
                        label: 'ID ${post.id}',
                        color: accent,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.person_rounded,
                        label: 'User ${post.userId}',
                        color: accent,
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title section
                  Text(
                    'TITLE',
                    style: tt.labelSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.title,
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider with label
                  Row(
                    children: [
                      Expanded(
                        child:
                            Divider(color: cs.outlineVariant, endIndent: 12),
                      ),
                      Text(
                        'CONTENT',
                        style: tt.labelSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Expanded(
                        child:
                            Divider(color: cs.outlineVariant, indent: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Body content card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1A1F2E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 60 : 14),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      post.body,
                      style: tt.bodyLarge?.copyWith(
                        height: 1.8,
                        color: cs.onSurface.withAlpha(210),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 40 : 20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
