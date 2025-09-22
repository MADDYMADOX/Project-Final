import 'package:flutter/material.dart';

/// Social login button component
class SocialLoginButton extends StatefulWidget {
  final String text;
  final String assetPath;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final SocialProvider provider;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.assetPath,
    required this.provider,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  State<SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<SocialLoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

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
    final isEnabled = widget.isEnabled && !widget.isLoading;
    final colors = _getProviderColors();

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
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isEnabled ? colors.backgroundColor : colors.disabledColor,
                border: Border.all(
                  color: isEnabled ? colors.borderColor : colors.disabledBorderColor,
                  width: 1,
                ),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: colors.shadowColor.withAlpha((0.1 * 255).round()),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
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
                              valueColor: AlwaysStoppedAnimation<Color>(colors.textColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ] else ...[
                          // Social provider icon
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: colors.iconBackgroundColor,
                            ),
                            child: Center(
                              child: Text(
                                _getProviderIcon(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colors.iconColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          widget.text,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isEnabled ? colors.textColor : colors.disabledTextColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.25,
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

  _SocialProviderColors _getProviderColors() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    switch (widget.provider) {
      case SocialProvider.google:
        return _SocialProviderColors(
          backgroundColor: Colors.white,
          borderColor: const Color(0xFFDADCE0),
          shadowColor: Colors.black,
          textColor: const Color(0xFF3C4043),
          iconBackgroundColor: Colors.white,
          iconColor: const Color(0xFF4285F4),
          disabledColor: Colors.white.withAlpha((0.5 * 255).round()),
          disabledBorderColor: const Color(0xFFDADCE0).withAlpha((0.5 * 255).round()),
          disabledTextColor: const Color(0xFF3C4043).withAlpha((0.5 * 255).round()),
        );
      case SocialProvider.github:
        return _SocialProviderColors(
          backgroundColor: isDark ? const Color(0xFF24292E) : const Color(0xFF24292E),
          borderColor: isDark ? const Color(0xFF444D56) : const Color(0xFF444D56),
          shadowColor: Colors.black,
          textColor: Colors.white,
          iconBackgroundColor: const Color(0xFF24292E),
          iconColor: Colors.white,
          disabledColor: const Color(0xFF24292E).withAlpha((0.5 * 255).round()),
          disabledBorderColor: const Color(0xFF444D56).withAlpha((0.5 * 255).round()),
          disabledTextColor: Colors.white.withAlpha((0.5 * 255).round()),
        );
      case SocialProvider.apple:
        return _SocialProviderColors(
          backgroundColor: isDark ? Colors.white : Colors.black,
          borderColor: isDark ? Colors.white.withAlpha((0.2 * 255).round()) : Colors.black.withAlpha((0.2 * 255).round()),
          shadowColor: isDark ? Colors.white : Colors.black,
          textColor: isDark ? Colors.black : Colors.white,
          iconBackgroundColor: isDark ? Colors.white : Colors.black,
          iconColor: isDark ? Colors.black : Colors.white,
          disabledColor: (isDark ? Colors.white : Colors.black).withAlpha((0.5 * 255).round()),
          disabledBorderColor: (isDark ? Colors.white : Colors.black).withAlpha((0.1 * 255).round()),
          disabledTextColor: (isDark ? Colors.black : Colors.white).withAlpha((0.5 * 255).round()),
        );
    }
  }

  String _getProviderIcon() {
    switch (widget.provider) {
      case SocialProvider.google:
        return 'G';
      case SocialProvider.github:
        return 'G';
      case SocialProvider.apple:
        return 'A';
    }
  }
}

enum SocialProvider {
  google,
  github,
  apple,
}

class _SocialProviderColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final Color textColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color disabledColor;
  final Color disabledBorderColor;
  final Color disabledTextColor;

  _SocialProviderColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.shadowColor,
    required this.textColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.disabledColor,
    required this.disabledBorderColor,
    required this.disabledTextColor,
  });
}
