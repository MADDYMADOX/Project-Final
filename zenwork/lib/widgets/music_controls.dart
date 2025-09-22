import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../utils/app_colors.dart';
import 'glass_card.dart';

/// Music control widget for ambient sound playback
class MusicControls extends ConsumerWidget {
  const MusicControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioServiceProvider);
    final theme = Theme.of(context);

    if (audioState.currentSound == null) {
      return const SizedBox.shrink();
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sound info
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSoundIcon(audioState.currentSound!.id),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audioState.currentSound!.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Ambient Sound',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress bar (for visual feedback, ambient sounds loop)
          LinearProgressIndicator(
            value: audioState.duration.inSeconds > 0 
                ? audioState.position.inSeconds / audioState.duration.inSeconds 
                : 0.0,
            backgroundColor: theme.colorScheme.outline.withAlpha((0.2 * 255).round()),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          
          const SizedBox(height: 16),
          
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Volume down
              _ControlButton(
                icon: Icons.volume_down_rounded,
                onPressed: () {
                  final newVolume = (audioState.volume - 0.1).clamp(0.0, 1.0);
                  ref.read(audioServiceProvider.notifier).setVolume(newVolume);
                },
              ),
              
              // Play/Pause
              _ControlButton(
                icon: audioState.isLoading
                    ? Icons.hourglass_empty_rounded
                    : audioState.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                onPressed: audioState.isLoading
                    ? null
                    : () {
                        ref.read(audioServiceProvider.notifier).togglePlayPause();
                      },
                isPrimary: true,
                size: 56,
              ),
              
              // Volume up
              _ControlButton(
                icon: Icons.volume_up_rounded,
                onPressed: () {
                  final newVolume = (audioState.volume + 0.1).clamp(0.0, 1.0);
                  ref.read(audioServiceProvider.notifier).setVolume(newVolume);
                },
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Volume slider
          Row(
            children: [
              Icon(
                Icons.volume_off_rounded,
                size: 16,
                color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
              ),
              Expanded(
                child: Slider(
                  value: audioState.volume,
                  onChanged: (value) {
                    ref.read(audioServiceProvider.notifier).setVolume(value);
                  },
                  activeColor: AppColors.primary,
                  inactiveColor: theme.colorScheme.outline.withAlpha((0.2 * 255).round()),
                ),
              ),
              Icon(
                Icons.volume_up_rounded,
                size: 16,
                color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
              ),
            ],
          ),
          
          // Stop button
          TextButton.icon(
            onPressed: () {
              ref.read(audioServiceProvider.notifier).stop();
            },
            icon: const Icon(Icons.stop_rounded, size: 16),
            label: const Text('Stop'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
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

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final double size;

  const _ControlButton({
    required this.icon,
    this.onPressed,
    this.isPrimary = false,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isPrimary
            ? const LinearGradient(colors: AppColors.primaryGradient)
            : null,
        color: isPrimary ? null : Colors.white.withAlpha((0.1 * 255).round()),
        border: Border.all(
          color: isPrimary ? Colors.transparent : Colors.white.withAlpha((0.2 * 255).round()),
          width: 1,
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppColors.primary.withAlpha((0.3 * 255).round()),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: isPrimary ? Colors.white : AppColors.primary,
          size: isPrimary ? 28 : 20,
        ),
      ),
    );
  }
}