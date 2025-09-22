import 'package:flutter/material.dart';
import '../models/ambient_sound.dart';
import '../utils/app_colors.dart';
import 'glass_card.dart';

/// Premium sound card with background imagery and animations
class SoundCard extends StatefulWidget {
  final AmbientSound sound;
  final bool isSelected;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback? onPreview;

  const SoundCard({
    super.key,
    required this.sound,
    required this.isSelected,
    required this.isPlaying,
    required this.onTap,
    this.onPreview,
  });

  @override
  State<SoundCard> createState() => _SoundCardState();
}

class _SoundCardState extends State<SoundCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SoundCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final soundGradient = _getSoundGradient(widget.sound.id);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isPlaying ? _pulseAnimation.value : 1.0,
          child: Container(
            height: 120,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: AnimatedGlassCard(
              onTap: widget.onTap,
              isSelected: widget.isSelected,
              padding: EdgeInsets.zero,
              child: Stack(
                children: [
                  // Background gradient with sound theme
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: soundGradient,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  
                  // Overlay for better text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha((0.3 * 255).round()),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Animated sound icon
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.2 * 255).round()),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withAlpha((0.3 * 255).round()),
                              width: 1,
                            ),
                          ),
                          child: Transform.scale(
                            scale: widget.isPlaying ? (1.0 + (_waveAnimation.value * 0.1)) : 1.0,
                            child: Icon(
                              _getSoundIcon(widget.sound.id),
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Sound info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.sound.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withAlpha((0.3 * 255).round()),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.sound.description,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withAlpha((0.9 * 255).round()),
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withAlpha((0.3 * 255).round()),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        // Play/pause button
                        if (widget.onPreview != null)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha((0.2 * 255).round()),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withAlpha((0.3 * 255).round()),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              onPressed: widget.onPreview,
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  widget.isPlaying 
                                      ? Icons.pause_rounded 
                                      : Icons.play_arrow_rounded,
                                  key: ValueKey(widget.isPlaying),
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Selection indicator
                  if (widget.isSelected)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((0.1 * 255).round()),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Selected',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Color> _getSoundGradient(String soundId) {
    switch (soundId) {
      case 'rain':
        return [const Color(0xFF4A90E2), const Color(0xFF7B68EE)];
      case 'lofi':
        return [const Color(0xFFFF6B6B), const Color(0xFF4ECDC4)];
      case 'piano':
        return [const Color(0xFF667EEA), const Color(0xFF764BA2)];
      case 'nature':
        return [const Color(0xFF56AB2F), const Color(0xFFA8E6CF)];
      case 'white_noise':
        return [const Color(0xFF8E9AAF), const Color(0xFFCBC0D3)];
      case 'ocean':
        return [const Color(0xFF2196F3), const Color(0xFF21CBF3)];
      case 'forest':
        return [const Color(0xFF134E5E), const Color(0xFF71B280)];
      case 'cafe':
        return [const Color(0xFFD2691E), const Color(0xFFCD853F)];
      case 'thunder':
        return [const Color(0xFF2C3E50), const Color(0xFF4CA1AF)];
      case 'bells':
        return [const Color(0xFFB794F6), const Color(0xFFE879F9)];
      default:
        return [const Color(0xFF667EEA), const Color(0xFF764BA2)];
    }
  }

  IconData _getSoundIcon(String soundId) {
    switch (soundId) {
      case 'rain':
        return Icons.water_drop_rounded;
      case 'lofi':
        return Icons.music_note_rounded;
      case 'piano':
        return Icons.piano_rounded;
      case 'nature':
        return Icons.park_rounded;
      case 'white_noise':
        return Icons.graphic_eq_rounded;
      case 'ocean':
        return Icons.waves_rounded;
      case 'forest':
        return Icons.forest_rounded;
      case 'cafe':
        return Icons.local_cafe_rounded;
      case 'thunder':
        return Icons.thunderstorm_rounded;
      case 'bells':
        return Icons.notifications_none_rounded;
      default:
        return Icons.audiotrack_rounded;
    }
  }
}