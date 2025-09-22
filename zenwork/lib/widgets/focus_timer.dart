import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../models/focus_session.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import 'glass_card.dart';

/// Premium circular timer with glowing animations and glassmorphism
class FocusTimer extends ConsumerStatefulWidget {
  const FocusTimer({super.key});

  @override
  ConsumerState<FocusTimer> createState() => _FocusTimerState();
}

class _FocusTimerState extends ConsumerState<FocusTimer>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(sessionTimerProvider);
    final theme = Theme.of(context);

    // Control animations based on timer state
    if (timerState.isRunning && !timerState.isPaused) {
      _glowController.repeat(reverse: true);
      _pulseController.repeat(reverse: true);
      _rotationController.repeat();
    } else {
      _glowController.stop();
      _pulseController.stop();
      _rotationController.stop();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_glowController, _pulseController, _rotationController]),
      builder: (context, child) {
        return Transform.scale(
          scale: timerState.isRunning ? _pulseAnimation.value : 1.0,
          child: SizedBox(
            width: 320,
            height: 320,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow effect
                if (timerState.isRunning)
                  Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha((_glowAnimation.value * 0.4 * 255).round()),
                          blurRadius: 60,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                
                // Rotating gradient ring
                if (timerState.isRunning)
                  Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            AppColors.primary.withAlpha((0.1 * 255).round()),
                            AppColors.primaryLight.withAlpha((0.3 * 255).round()),
                            AppColors.secondary.withAlpha((0.2 * 255).round()),
                            AppColors.primary.withAlpha((0.1 * 255).round()),
                          ],
                          stops: const [0.0, 0.3, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                
                // Main timer container with glassmorphism
                GlassCard(
                  borderRadius: 150,
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: Stack(
                      children: [
                        // Progress ring
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _ProgressRingPainter(
                              progress: timerState.progress,
                              isActive: timerState.isRunning,
                              glowIntensity: _glowAnimation.value,
                            ),
                          ),
                        ),
                        
                        // Timer content
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Time display
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: timerState.isRunning 
                                      ? AppColors.primaryGradient
                                      : [
                                          theme.colorScheme.onSurface,
                                          theme.colorScheme.onSurface,
                                        ],
                                ).createShader(bounds),
                                child: Text(
                                  timerState.remainingTime.toTimerString(),
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 48,
                                    color: Colors.white,
                                    letterSpacing: -2,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Status text
                              Text(
                                _getStatusText(timerState),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                              
                              // Motivational text
                              if (timerState.isRunning && !timerState.isPaused) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _getMotivationalText(timerState.progress),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary.withAlpha((0.8 * 255).round()),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                              
                              // Control buttons
                              if (timerState.isRunning) ...[
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _PremiumTimerButton(
                                      icon: timerState.isPaused 
                                          ? Icons.play_arrow_rounded 
                                          : Icons.pause_rounded,
                                      onPressed: () {
                                        if (timerState.isPaused) {
                                          ref.read(sessionTimerProvider.notifier).resumeSession();
                                          // Resume audio
                                          ref.read(audioServiceProvider.notifier).resume();
                                        } else {
                                          ref.read(sessionTimerProvider.notifier).pauseSession();
                                          // Pause audio
                                          ref.read(audioServiceProvider.notifier).pause();
                                        }
                                      },
                                      isPrimary: true,
                                    ),
                                    const SizedBox(width: 20),
                                    _PremiumTimerButton(
                                      icon: Icons.stop_rounded,
                                      onPressed: () {
                                        final timer = ref.read(sessionTimerProvider);
                                        // If a session is running, record it as an early stop
                                        if (timer.isRunning && timer.startTime != null) {
                                          final taskType = ref.read(selectedTaskTypeProvider);
                                          final sound = ref.read(selectedSoundProvider);
                                          if (taskType != null && sound != null) {
                                            final session = FocusSession(
                                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                                              taskType: taskType,
                                              soundId: sound.id,
                                              startTime: timer.startTime!,
                                              endTime: DateTime.now(),
                                              plannedDurationMinutes: timer.plannedDuration.inMinutes,
                                              actualDurationMinutes: timer.elapsedTime.inMinutes,
                                              focusScore: FocusSession.calculateFocusScore(
                                                plannedMinutes: timer.plannedDuration.inMinutes,
                                                actualMinutes: timer.elapsedTime.inMinutes,
                                                interruptions: 0,
                                              ),
                                            );
                                            ref.read(focusSessionsProvider.notifier).addSession(session);
                                          }
                                        }

                                        ref.read(sessionTimerProvider.notifier).stopSession();
                                        // Stop audio
                                        ref.read(audioServiceProvider.notifier).stop();
                                      },
                                      isPrimary: false,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusText(SessionTimerState timerState) {
    if (!timerState.isRunning) return 'Ready to Focus';
    if (timerState.isPaused) return 'Paused';
    
    final progress = timerState.progress;
    if (progress < 0.25) return 'Getting Started';
    if (progress < 0.5) return 'Building Momentum';
    if (progress < 0.75) return 'In the Zone';
    return 'Final Push';
  }

  String _getMotivationalText(double progress) {
    if (progress < 0.25) return 'You\'ve got this! 💪';
    if (progress < 0.5) return 'Great progress! 🚀';
    if (progress < 0.75) return 'Keep going strong! ⭐';
    return 'Almost there! 🎯';
  }
}

class _PremiumTimerButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _PremiumTimerButton({
    required this.icon,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  State<_PremiumTimerButton> createState() => _PremiumTimerButtonState();
}

class _PremiumTimerButtonState extends State<_PremiumTimerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.isPrimary
                    ? const LinearGradient(
                        colors: AppColors.primaryGradient,
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white.withAlpha((0.1 * 255).round()),
                          Colors.white.withAlpha((0.05 * 255).round()),
                        ],
                      ),
                border: Border.all(
                  color: widget.isPrimary
                      ? Colors.transparent
                      : Colors.white.withAlpha((0.2 * 255).round()),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isPrimary
                        ? AppColors.primary.withAlpha((0.3 * 255).round())
                        : Colors.black.withAlpha((0.1 * 255).round()),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: widget.isPrimary ? Colors.white : AppColors.primary,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final bool isActive;
  final double glowIntensity;

  _ProgressRingPainter({
    required this.progress,
    required this.isActive,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    // Background ring
    final backgroundPaint = Paint()
      ..color = AppColors.primary.withAlpha((0.1 * 255).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Progress ring
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: AppColors.primaryGradient,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
      
      // Add glow effect when active
      if (isActive) {
        final glowPaint = Paint()
          ..shader = LinearGradient(
            colors: AppColors.primaryGradient.map(
              (color) => color.withAlpha((glowIntensity * 0.5 * 255).round())
            ).toList(),
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          2 * math.pi * progress,
          false,
          glowPaint,
        );
      }
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}