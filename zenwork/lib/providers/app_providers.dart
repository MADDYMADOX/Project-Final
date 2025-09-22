import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_type.dart';
import '../models/ambient_sound.dart';
import '../models/focus_session.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../services/recommendation_service.dart';


/// Provider for storage service
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Provider for the audio service
final audioServiceProvider = StateNotifierProvider<AudioService, AudioState>((ref) {
  return AudioService();
});

/// Provider for selected task type
final isSessionActiveProvider = StateProvider<bool>((ref) => false);
final currentSessionProvider = StateProvider<FocusSession?>((ref) => null);

/// Provider for selected task type
final selectedTaskTypeProvider = StateProvider<TaskType?>((ref) {
  final taskTypeString = StorageService.getLastTaskType();
  if (taskTypeString == null) return null;
  
  try {
    return TaskType.values.firstWhere((type) => type.name == taskTypeString);
  } catch (e) {
    return null;
  }
});

/// Provider for selected ambient sound
final selectedSoundProvider = StateProvider<AmbientSound?>((ref) {
  final soundId = StorageService.getDefaultSound();
  if (soundId == null) return null;
  
  try {
    return AmbientSound.allSounds.firstWhere((sound) => sound.id == soundId);
  } catch (e) {
    return null;
  }
});

/// Provider for selected duration
final selectedDurationProvider = StateProvider<int>((ref) {
  return StorageService.getLastDuration() ?? 25;
});

/// Provider for recommended sounds based on selected task type
final recommendedSoundsProvider = Provider<List<AmbientSound>>((ref) {
  final taskType = ref.watch(selectedTaskTypeProvider);
  if (taskType == null) return AmbientSound.allSounds;
  
  return RecommendationService.getRecommendedSounds(taskType);
});

/// Provider for session timer state
final sessionTimerProvider = StateNotifierProvider<SessionTimerNotifier, SessionTimerState>((ref) {
  return SessionTimerNotifier();
});

/// Provider for focus sessions
final focusSessionsProvider = StateNotifierProvider<FocusSessionsNotifier, List<FocusSession>>((ref) {
  return FocusSessionsNotifier();
});

/// Provider for theme mode
final themeModeProvider = StateProvider<String>((ref) {
  return StorageService.getThemeMode();
});

/// Session timer state
class SessionTimerState {
  final Duration plannedDuration;
  final Duration elapsedTime;
  final bool isRunning;
  final bool isPaused;
  final DateTime? startTime;

  const SessionTimerState({
    this.plannedDuration = const Duration(minutes: 25),
    this.elapsedTime = Duration.zero,
    this.isRunning = false,
    this.isPaused = false,
    this.startTime,
  });

  SessionTimerState copyWith({
    Duration? plannedDuration,
    Duration? elapsedTime,
    bool? isRunning,
    bool? isPaused,
    DateTime? startTime,
  }) {
    return SessionTimerState(
      plannedDuration: plannedDuration ?? this.plannedDuration,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      startTime: startTime ?? this.startTime,
    );
  }

  double get progress {
    if (plannedDuration.inSeconds == 0) return 0.0;
    return (elapsedTime.inSeconds / plannedDuration.inSeconds).clamp(0.0, 1.0);
  }

  Duration get remainingTime {
    final remaining = plannedDuration - elapsedTime;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

/// Session timer notifier
class SessionTimerNotifier extends StateNotifier<SessionTimerState> {
  SessionTimerNotifier() : super(const SessionTimerState());
  
  void Function()? _onSessionComplete;
  
  void setOnSessionComplete(void Function() callback) {
    _onSessionComplete = callback;
  }

  void setPlannedDuration(Duration duration) {
    if (!state.isRunning) {
      state = state.copyWith(plannedDuration: duration);
    }
  }

  void startSession() {
    state = state.copyWith(
      isRunning: true,
      isPaused: false,
      startTime: DateTime.now(),
      elapsedTime: Duration.zero,
    );
    _startTimer();
  }

  void pauseSession() {
    state = state.copyWith(isPaused: true);
  }

  void resumeSession() {
    state = state.copyWith(isPaused: false);
  }

  void stopSession() {
    state = state.copyWith(
      isRunning: false,
      isPaused: false,
      elapsedTime: Duration.zero,
      startTime: null,
    );
  }

  void completeSession() {
    state = state.copyWith(
      isRunning: false,
      isPaused: false,
    );
    _onSessionComplete?.call();
  }

  void _startTimer() {
    if (!state.isRunning) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (state.isRunning && !state.isPaused) {
        final newElapsed = state.elapsedTime + const Duration(seconds: 1);
        state = state.copyWith(elapsedTime: newElapsed);
        
        if (newElapsed >= state.plannedDuration) {
          // Session completed
          completeSession();
        } else {
          _startTimer();
        }
      } else if (state.isRunning && state.isPaused) {
        _startTimer(); // Continue checking
      }
    });
  }
}

/// Focus sessions notifier
class FocusSessionsNotifier extends StateNotifier<List<FocusSession>> {
  FocusSessionsNotifier()
      : super(_sortSessions(StorageService.getAllSessions()));

  void addSession(FocusSession session) {
    StorageService.saveFocusSession(session);
    state = _sortSessions([...state, session]);
  }

  void refreshSessions() {
    state = _sortSessions(StorageService.getAllSessions());
  }

  List<FocusSession> getRecentSessions() {
    return StorageService.getRecentSessions();
  }

  List<FocusSession> getSessionsForDate(DateTime date) {
    return StorageService.getSessionsForDate(date);
  }

  static List<FocusSession> _sortSessions(List<FocusSession> sessions) {
    final sorted = sessions.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    return sorted;
  }
}