import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_colors.dart';

/// Reusable authentication input field with validation and styling
class AuthInputField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final String? errorText;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  const AuthInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.errorText,
    this.validator,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.onEditingComplete,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _borderColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: AppColors.primary,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    widget.focusNode?.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.focusNode?.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });
    
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: hasError 
                ? AppColors.error 
                : _isFocused 
                    ? AppColors.primary 
                    : theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        // Input field
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasError
                      ? AppColors.error
                      : _borderColorAnimation.value ?? 
                          (isDark 
                              ? Colors.white.withAlpha((0.1 * 255).round())
                              : Colors.black.withAlpha((0.1 * 255).round())),
                  width: hasError ? 2 : (_isFocused ? 2 : 1),
                ),
                boxShadow: _isFocused && !hasError
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha((0.1 * 255).round()),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark 
                            ? [
                                Colors.white.withAlpha((0.05 * 255).round()),
                                Colors.white.withAlpha((0.02 * 255).round()),
                              ]
                            : [
                                Colors.white.withAlpha((0.8 * 255).round()),
                                Colors.white.withAlpha((0.6 * 255).round()),
                              ],
                      ),
                    ),
                    child: TextFormField(
                      controller: widget.controller,
                      keyboardType: widget.keyboardType,
                      obscureText: widget.obscureText,
                      enabled: widget.enabled,
                      onTap: widget.onTap,
                      focusNode: widget.focusNode,
                      onEditingComplete: widget.onEditingComplete,
                      onChanged: widget.onChanged,
                      autofocus: widget.autofocus,
                      maxLines: widget.maxLines,
                      maxLength: widget.maxLength,
                      textCapitalization: widget.textCapitalization,
                      inputFormatters: widget.inputFormatters,
                      validator: widget.validator,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha((0.5 * 255).round()),
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: widget.prefixIcon != null
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: widget.prefixIcon,
                              )
                            : null,
                        suffixIcon: widget.suffixIcon != null
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: widget.suffixIcon,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        counterText: '',
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        // Error text
        if (hasError) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: AppColors.error,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
