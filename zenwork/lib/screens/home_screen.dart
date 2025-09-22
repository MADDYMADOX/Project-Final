import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_type.dart';
import '../models/ambient_sound.dart';
import '../providers/app_providers.dart';
import '../services/recommendation_service.dart';
import '../services/storage_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/task_type_card.dart';
import '../widgets/sound_card.dart';
import '../widgets/focus_timer.dart';
import '../widgets/music_controls.dart';
import '../models/focus_session.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

/// Main home screen with task selection and session management
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedDurationMinutes = AppConstants.defaultTimerDuration;

  @override
  void initState() {
    super.initState();
    // Set up session completion callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionTimerProvider.notifier).setOnSessionComplete(() {
        _handleSessionCompletion();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedTaskType = ref.watch(selectedTaskTypeProvider);
    final selectedSound = ref.watch(selectedSoundProvider);
    final recommendedSounds = ref.watch(recommendedSoundsProvider);
    final timerState = ref.watch(sessionTimerProvider);
    final theme = Theme.of(context);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Zen Work'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _buildWelcomeSection(theme),
              const SizedBox(height: AppConstants.largePadding),

              // Task type selection
              if (!timerState.isRunning) ...[
                _buildSectionTitle('Choose Your Task', theme),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildTaskTypeGrid(),
                const SizedBox(height: AppConstants.largePadding),
              ],

              // Sound selection
              if (selectedTaskType != null && !timerState.isRunning) ...[
                _buildSectionTitle('Select Ambient Sound', theme),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildSoundList(recommendedSounds),
                const SizedBox(height: AppConstants.largePadding),
              ],

              // Duration selection
              if (selectedTaskType != null && selectedSound != null && !timerState.isRunning) ...[
                _buildSectionTitle('Session Duration', theme),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildDurationSelector(),
                const SizedBox(height: AppConstants.largePadding),
              ],

              // Timer and controls
              if (selectedTaskType != null && selectedSound != null) ...[
                Center(
                  child: Column(
                    children: [
                      const FocusTimer(),
                      const SizedBox(height: AppConstants.largePadding),
                      if (!timerState.isRunning)
                        _buildStartButton()
                      else
                        _buildSessionInfo(selectedTaskType, selectedSound),
                    ],
                  ),
                ),
              ],
              
              // Music controls (show when audio is playing)
              const MusicControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: AppColors.primaryGradient,
            ).createShader(bounds),
            child: Text(
              'Welcome to Zen Work',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Enhance your focus with ambient sounds tailored to your work type. Create the perfect environment for deep work.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.accentGradient,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '✨ Premium Focus Experience',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildTaskTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: AppConstants.defaultPadding,
        mainAxisSpacing: AppConstants.defaultPadding,
      ),
      itemCount: TaskType.values.length,
      itemBuilder: (context, index) {
        final taskType = TaskType.values[index];
        final isSelected = ref.watch(selectedTaskTypeProvider) == taskType;

        return TaskTypeCard(
          taskType: taskType,
          isSelected: isSelected,
          onTap: () {
            ref.read(selectedTaskTypeProvider.notifier).state = taskType;
            StorageService.saveLastTaskType(taskType.name);
            
            // Auto-select recommended sound
            final recommendedSound = RecommendationService.getTopRecommendation(taskType);
            ref.read(selectedSoundProvider.notifier).state = recommendedSound;
          },
        );
      },
    );
  }

  Widget _buildSoundList(List<AmbientSound> sounds) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sounds.length,
      itemBuilder: (context, index) {
        final sound = sounds[index];
        final isSelected = ref.watch(selectedSoundProvider) == sound;
        final audioState = ref.watch(audioServiceProvider);
        final isPlaying = audioState.currentSound?.id == sound.id && audioState.isPlaying;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: SoundCard(
            sound: sound,
            isSelected: isSelected,
            isPlaying: isPlaying,
            onTap: () {
              ref.read(selectedSoundProvider.notifier).state = sound;
            },
            onPreview: () async {
              final audioService = ref.read(audioServiceProvider.notifier);
              if (isPlaying) {
                await audioService.pause();
              } else {
                await audioService.playSound(sound);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildDurationSelector() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.timer_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Session Duration',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Selected: $_selectedDurationMinutes minutes',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AppConstants.timerDurations.map((duration) {
              final isSelected = duration == _selectedDurationMinutes;
              return AnimatedContainer(
                duration: AppConstants.mediumAnimation,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDurationMinutes = duration;
                    });
                    ref.read(sessionTimerProvider.notifier)
                        .setPlannedDuration(Duration(minutes: duration));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: AppColors.primaryGradient,
                            )
                          : null,
                      color: isSelected
                          ? null
                          : Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      '${duration}m',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _startSession,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Start Focus Session',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo(TaskType taskType, AmbientSound sound) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.accentGradient,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '🎯 Focus Session Active',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.getTaskTypeColor(taskType.displayName).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTaskIcon(taskType),
                  color: AppColors.getTaskTypeColor(taskType.displayName),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                taskType.displayName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '•',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                sound.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTaskIcon(TaskType taskType) {
    switch (taskType) {
      case TaskType.writing:
        return Icons.edit_note_rounded;
      case TaskType.coding:
        return Icons.code_rounded;
      case TaskType.studying:
        return Icons.school_rounded;
      case TaskType.reading:
        return Icons.menu_book_rounded;
      case TaskType.creative:
        return Icons.palette_rounded;
      case TaskType.other:
        return Icons.work_rounded;
    }
  }

  Future<void> _startSession() async {
    final taskType = ref.read(selectedTaskTypeProvider);
    final sound = ref.read(selectedSoundProvider);
    
    if (taskType == null || sound == null) return;

    // Set planned duration
    ref.read(sessionTimerProvider.notifier)
        .setPlannedDuration(Duration(minutes: _selectedDurationMinutes));

    // Start timer immediately to avoid waiting on audio engine
    ref.read(sessionTimerProvider.notifier).startSession();

    // Kick off audio without blocking UI
    // ignore: unawaited_futures
    ref.read(audioServiceProvider.notifier).playSound(sound);
  }

  void _handleSessionCompletion() {
    final taskType = ref.read(selectedTaskTypeProvider);
    final sound = ref.read(selectedSoundProvider);
    final timerState = ref.read(sessionTimerProvider);
    
    if (taskType == null || sound == null) return;

    // Create and save the session
    final session = FocusSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskType: taskType,
      soundId: sound.id,
      startTime: timerState.startTime ?? DateTime.now(),
      endTime: DateTime.now(),
      plannedDurationMinutes: timerState.plannedDuration.inMinutes,
      actualDurationMinutes: timerState.elapsedTime.inMinutes,
      focusScore: FocusSession.calculateFocusScore(
        plannedMinutes: timerState.plannedDuration.inMinutes,
        actualMinutes: timerState.elapsedTime.inMinutes,
        interruptions: 0, // TODO: Track interruptions
      ),
    );

    // Stop audio
    ref.read(audioServiceProvider.notifier).stop();

    // Save session
    ref.read(focusSessionsProvider.notifier).addSession(session);

    // Show completion dialog
    _showSessionCompletionDialog(session);
  }

  void _showSessionCompletionDialog(FocusSession session) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.celebration_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Session Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompletionStat('Duration', '${session.actualDurationMinutes} minutes'),
            _buildCompletionStat('Focus Score', '${session.focusScore}/100'),
            _buildCompletionStat('Performance', session.focusScoreLabel),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.getFocusScoreColor(session.focusScore).withOpacity(0.1),
                    AppColors.getFocusScoreColor(session.focusScore).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: AppColors.getFocusScoreColor(session.focusScore),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getMotivationalMessage(session.focusScore),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Reset selections for next session
              ref.read(selectedTaskTypeProvider.notifier).state = null;
              ref.read(selectedSoundProvider.notifier).state = null;
              // Ensure audio is stopped
              ref.read(audioServiceProvider.notifier).stop();
            },
            child: const Text('New Session'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Ensure audio is stopped
              ref.read(audioServiceProvider.notifier).stop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage(int score) {
    if (score >= 90) return 'Outstanding focus! You\'re in the zone! 🎯';
    if (score >= 80) return 'Great job! Your concentration is improving! 🚀';
    if (score >= 70) return 'Good work! Keep building that focus muscle! 💪';
    if (score >= 60) return 'Nice effort! Every session makes you stronger! ⭐';
    return 'Keep going! Focus is a skill that improves with practice! 🌱';
  }
}