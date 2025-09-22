import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// Reusable authentication button with loading state and styling
class AuthButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final AuthButtonType type;
  final Widget? icon;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.type = AuthButtonType.primary,
    this.icon,
    this.width,
    this.height = 56,
    this.padding,
  });

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    if (widget.isEnabled && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _onTapUp() {
    if (widget.isEnabled && !widget.isLoading) {
      _animationController.reverse();
      widget.onPressed?.call();
    }
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final isEnabled = widget.isEnabled && !widget.isLoading;
    final buttonColors = _getButtonColors(isDark);
    final textColor = _getTextColor(isDark);

    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: isEnabled ? buttonColors.gradient : null,
                color: isEnabled ? null : buttonColors.disabledColor,
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: buttonColors.shadowColor.withAlpha((0.3 * 255).round()),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        if (_glowAnimation.value > 0)
                          BoxShadow(
                            color: buttonColors.glowColor.withAlpha(
                              (0.3 * _glowAnimation.value * 255).round(),
                            ),
                            blurRadius: 30,
                            offset: const Offset(0, 0),
                          ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: isEnabled ? widget.onPressed : null,
                  child: Container(
                    padding: widget.padding ?? const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading) ...[
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(textColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ] else if (widget.icon != null) ...[
                          widget.icon!,
                          const SizedBox(width: 12),
                        ],
                        Text(
                          widget.text,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _ButtonColors _getButtonColors(bool isDark) {
    switch (widget.type) {
      case AuthButtonType.primary:
        return _ButtonColors(
          gradient: const LinearGradient(
            colors: AppColors.primaryGradient,
          ),
          shadowColor: AppColors.primary,
          glowColor: AppColors.primary,
          disabledColor: isDark 
              ? Colors.white.withAlpha((0.1 * 255).round())
              : Colors.black.withAlpha((0.1 * 255).round()),
        );
      case AuthButtonType.secondary:
        return _ButtonColors(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.white.withAlpha((0.1 * 255).round()), Colors.white.withAlpha((0.05 * 255).round())]
                : [Colors.black.withAlpha((0.05 * 255).round()), Colors.black.withAlpha((0.02 * 255).round())],
          ),
          shadowColor: isDark ? Colors.white : Colors.black,
          glowColor: isDark ? Colors.white : Colors.black,
          disabledColor: isDark 
              ? Colors.white.withAlpha((0.05 * 255).round())
              : Colors.black.withAlpha((0.05 * 255).round()),
        );
      case AuthButtonType.outline:
        return _ButtonColors(
          gradient: null,
          shadowColor: AppColors.primary,
          glowColor: AppColors.primary,
          disabledColor: Colors.transparent,
        );
    }
  }

  Color _getTextColor(bool isDark) {
    if (!widget.isEnabled || widget.isLoading) {
      return isDark 
          ? Colors.white.withAlpha((0.3 * 255).round())
          : Colors.black.withAlpha((0.3 * 255).round());
    }

    switch (widget.type) {
      case AuthButtonType.primary:
        return Colors.white;
      case AuthButtonType.secondary:
        return isDark ? Colors.white : Colors.black;
      case AuthButtonType.outline:
        return AppColors.primary;
    }
  }
}

enum AuthButtonType {
  primary,
  secondary,
  outline,
}

class _ButtonColors {
  final Gradient? gradient;
  final Color shadowColor;
  final Color glowColor;
  final Color disabledColor;

  _ButtonColors({
    this.gradient,
    required this.shadowColor,
    required this.glowColor,
    required this.disabledColor,
  });
}

