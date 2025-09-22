import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Premium animated gradient background with depth
class GradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  final bool animated;
  final Duration animationDuration;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.animated = true,
    this.animationDuration = const Duration(seconds: 8),
  });

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _controller = AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      );
      _animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = widget.colors ?? 
        (isDark ? AppColors.backgroundGradientDark : AppColors.backgroundGradient);

    if (!widget.animated) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
              stops: [
                0.0,
                0.3 + (_animation.value * 0.4),
                1.0,
              ],
              transform: GradientRotation(_animation.value * 0.1),
            ),
          ),
          child: Stack(
            children: [
              // Subtle overlay for depth
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.5,
                    colors: [
                      Colors.white.withAlpha(((isDark ? 0.02 : 0.1) * 255).round()),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}