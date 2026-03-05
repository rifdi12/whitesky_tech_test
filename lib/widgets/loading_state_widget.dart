import 'package:flutter/material.dart';

/// Full-screen skeleton with a shimmer sweep animation.
class LoadingStateWidget extends StatefulWidget {
  const LoadingStateWidget({super.key});

  @override
  State<LoadingStateWidget> createState() => _LoadingStateWidgetState();
}

class _LoadingStateWidgetState extends State<LoadingStateWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _shimmer = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) {
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: 7,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => _SkeletonCard(shimmerValue: _shimmer.value),
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.shimmerValue});

  final double shimmerValue;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF1A1F2E)
        : const Color(0xFFE8ECF4);
    final highlightColor = isDark
        ? const Color(0xFF2A3147)
        : const Color(0xFFF5F7FB);

    return Container(
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [baseColor, highlightColor, baseColor],
          stops: [
            (shimmerValue - 0.5).clamp(0.0, 1.0),
            shimmerValue.clamp(0.0, 1.0),
            (shimmerValue + 0.5).clamp(0.0, 1.0),
          ],
        ).createShader(bounds),
        blendMode: BlendMode.srcATop,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User badge row
              Row(
                children: [
                  _bar(width: 72, height: 20, radius: 20),
                  const Spacer(),
                  _bar(width: 28, height: 12, radius: 6),
                ],
              ),
              const SizedBox(height: 12),
              // Title lines
              _bar(width: double.infinity, height: 14, radius: 6),
              const SizedBox(height: 6),
              _bar(width: 200, height: 14, radius: 6),
              const SizedBox(height: 12),
              // Body lines
              _bar(width: double.infinity, height: 10, radius: 5),
              const SizedBox(height: 5),
              _bar(width: double.infinity, height: 10, radius: 5),
              const SizedBox(height: 5),
              _bar(width: 140, height: 10, radius: 5),
              const SizedBox(height: 12),
              // Footer
              Row(
                children: [
                  _bar(width: 56, height: 20, radius: 8),
                  const Spacer(),
                  _bar(width: 12, height: 12, radius: 6),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
